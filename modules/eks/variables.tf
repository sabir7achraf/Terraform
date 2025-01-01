variable "vpc_id" {
  description = "ID du VPC"
}

variable "project_name" {
  description = "Nom de votre projet"
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "Type d'instance EC2"
}

variable "desired_nodes" {
  description = "Nombre de nodes EKS"
}

variable "min_nodes" {
  description = "Nombre minimum de nodes EKS"
}

variable "max_nodes" {
  description = "Nombre maximum de nodes EKS"
}

variable "instance_profile_name" {
  description = "Nom du profil d'instance"
}
variable "sg_worker_node" {
  description = "Nom du SG worker node"
}

variable "sg_control_plane" {
  description = "Nom du SG control plane"
}
variable "domain_name" {
  description = "Nom du domaine"
}
variable "sg_alb" {
  description = "ID du Security Group pour l'ALB"
  type        = string
}
output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}
