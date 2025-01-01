output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig" {
  value     = <<KUBECONFIG
 apiVersion: v1
 clusters:
   - cluster:
       server: ${aws_eks_cluster.cluster.endpoint}
       certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
     name: kubernetes
 contexts:
   - context:
       cluster: kubernetes
       user: aws
     name: aws
 current-context: aws
 kind: Config
 preferences: {}
 users:
   - name: aws
     user:
       exec:
         apiVersion: client.authentication.k8s.io/v1beta1
         command: aws
         args:
           - "eks"
           - "get-token"
           - "--cluster-name"
           - "${aws_eks_cluster.cluster.name}"
         #                env:
         #                  AWS_PROFILE: ""
 KUBECONFIG
  sensitive = true
}

output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}


output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority.0.data
}
