output "control_plane_sg_id" {
  value = aws_security_group.control_plane_security_group.id
}

output "worker_node_sg_id" {
  value = aws_security_group.worker_security_group.id
}