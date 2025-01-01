output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint du cluster EKS"
}

output "kubeconfig" {
  value       = module.eks.kubeconfig
  description = "kubeconfig pour le cluster EKS"
  sensitive   = true
}

output "alb_dns_name" {
  value       = module.eks.alb_dns_name
  description = "DNS name de l'ALB"
}
