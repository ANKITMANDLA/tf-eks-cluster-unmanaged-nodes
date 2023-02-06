output "custom_domain" {
  value = var.custom_domain
}

output "eks_url" {
  value = module.eks_control_plane.endpoint
}

output "kube_config" {
  value = module.eks_kubeconfig.s3_location
}

output "active" {
  value = var.active
}