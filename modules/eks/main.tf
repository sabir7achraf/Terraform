# IAM Roles and Policies for EKS Cluster and Nodes
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "eks.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role" "eks_node" {
  name = "${var.project_name}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_container_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

# EKS Cluster and Node Group
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.sg_control_plane]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.project_name}-node-group"
  subnet_ids      = var.private_subnet_ids
  version         = "1.31"
  instance_types  = [var.instance_type]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = var.desired_nodes
    min_size     = var.min_nodes
    max_size     = var.max_nodes
  }

  node_role_arn = aws_iam_role.eks_node.arn

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy,
    aws_iam_role_policy_attachment.eks_node_container_policy,
    aws_iam_role_policy_attachment.eks_node_cni_policy,
  ]
}

# ALB Configuration
resource "aws_alb" "alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_alb]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No backend matched the request"
      status_code  = "404"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"


  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No backend matched the request"
      status_code  = "404"
    }
  }
}
resource "kubernetes_namespace" "main" {
  metadata {
    name = "app-namespace"
  }

  depends_on = [aws_eks_cluster.cluster, aws_eks_node_group.node_group]
}

resource "time_sleep" "wait_for_nodes" {
  depends_on = [kubernetes_namespace.main]

  create_duration = "60s" # or "1m"

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
# Déploiement MySQL
resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0" # Version stable de MySQL

          port {
            container_port = 3306
          }

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "securepassword" # Mot de passe sécurisé
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "gym" # Nom de la base de données
          }

          volume_mount {
            name       = "mysql-data"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "mysql-data"
          persistent_volume_claim {
            claim_name = "mysql-pvc"
          }
        }
      }
    }
  }
}

# Service MySQL
resource "kubernetes_service" "mysql_service" {
  metadata {
    name = "mysql-service"
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
}

# Backend Deployment
resource "kubernetes_deployment" "spring_app" {
  metadata {
    name = "spring-app"
    labels = {
      app = "spring-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "spring-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "spring-app"
        }
      }

      spec {
        container {
          name  = "spring-app"
          image = "sabir7achraf/lasanapp@sha256:3c05fdfef738a212d30c366f258b22766e5db0758437411186fa76e49eafec1e"

          port {
            container_port = 8080
          }

          env {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://mysql-service:3306/gym"
          }

          env {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "root"
          }

          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "spring_app_service" {
  metadata {
    name = "spring-app-service"
  }

  spec {
    selector = {
      app = "spring-app"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "NodePort"
  }
}


resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = kubernetes_namespace.main.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}
# Ingress
resource "kubernetes_ingress_v1" "main" {
  metadata {
    name      = "main-ingress"
    namespace = kubernetes_namespace.main.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"            = "alb"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
  }
  spec {
    rule {
      host = "3ellah" # Remplacez par votre domaine
      http {
        path {
          path = "/*" # Chemin pour les requêtes API
          backend {
            service {
              name = kubernetes_service.spring_app_service.metadata[0].name # Service Spring App
              port {
                number = 8080 # Port du service Spring App
              }
            }
          }
        }
      }
    }
  }
}

