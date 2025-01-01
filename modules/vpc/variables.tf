variable "vpc_cidr" {
  type = string
  description = "VPC CIDR block"
}

variable "project_name" {
  type = string
  description = "Project name"
}

variable "public_subnet_1_cidr" {
  type = string
  description = "Public Subnet 1 CIDR block"
}

variable "public_subnet_2_cidr" {
  type = string
  description = "Public Subnet 2 CIDR block"
}
variable "private_subnet_1_cidr" {
  type = string
  description = "Private Subnet 1 CIDR block"
}

variable "private_subnet_2_cidr" {
  type = string
  description = "Private Subnet 2 CIDR block"
}