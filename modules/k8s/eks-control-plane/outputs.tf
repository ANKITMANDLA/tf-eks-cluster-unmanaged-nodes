output "endpoint" {
  value = aws_eks_cluster.k8s_control_plane.endpoint
}

output "name" {
  value = aws_eks_cluster.k8s_control_plane.id
}