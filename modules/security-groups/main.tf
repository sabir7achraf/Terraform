resource "aws_security_group" "worker_nodes_sg" {
  name        = "worker-nodes-sg"
  description = "Security group for EKS Worker Nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restreindre à votre IP ou un bastion host
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Autoriser l'ALB
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block] # Autoriser l'accès à MySQL
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "worker-nodes-sg"
  }
}

# Security Group pour le Control Plane (géré par AWS)
resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Security group for EKS Control Plane"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block] # Autoriser les Worker Nodes
  }

  egress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block] # Autoriser les Worker Nodes
  }

  tags = {
    Name = "control-plane-sg"
  }
}

# Security Group pour l'ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block] # Autoriser les Worker Nodes
  }

  tags = {
    Name = "alb-sg"
  }
}

# Security Group pour MySQL (Amazon RDS)
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Security group for MySQL"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.eks_vpc.cidr_block] # Autoriser les Worker Nodes
  }

  tags = {
    Name = "mysql-sg"
  }
}