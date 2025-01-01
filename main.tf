module "vpc" {
  source                = "./modules/vpc"
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  project_name          = var.project_name
}

module "security-groups" {
  source       = "./modules/security-groups"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name


}

module "eks" {
  source                = "./modules/eks"
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_type         = var.instance_type
  desired_nodes         = var.desired_nodes
  min_nodes             = var.min_nodes
  max_nodes             = var.max_nodes
  instance_profile_name = var.instance_profile_name
  sg_worker_node        = module.security-groups.worker_node_sg_id
  sg_control_plane      = module.security-groups.control_plane_sg_id
  sg_alb                = module.security-groups.alb_security_group_id
  domain_name           = var.domain_name
}
