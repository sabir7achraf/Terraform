variable "region" {
  description = "AWS region"
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom de votre projet"
  default     = "monapp"
}

variable "az_name" {
  description = "Availability Zone unique"
  default     = "eu-west-3a"
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block pour le subnet public 1"
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block pour le subnet public 2"
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block pour le subnet privé 1"
  default     = "10.0.3.0/24"
}
variable "private_subnet_2_cidr" {
  description = "CIDR block pour le subnet privé 2"
  default     = "10.0.4.0/24"
}


variable "instance_type" {
  description = "Type d'instance EC2"
  default     = "t2.micro"
}

variable "desired_nodes" {
  description = "Nombre de nodes EKS"
  default     = 3
}

variable "min_nodes" {
  description = "Nombre minimum de nodes EKS"
  default     = 1
}

variable "max_nodes" {
  description = "Nombre maximum de nodes EKS"
  default     = 3
}

variable "instance_profile_name" {
  description = "Nom du profil d'instance"
  default     = "monapp-eks-node-profile"
}
variable "domain_name" {
  description = "Nom du domaine"
  default     = "monapp-paris.tech"
}
