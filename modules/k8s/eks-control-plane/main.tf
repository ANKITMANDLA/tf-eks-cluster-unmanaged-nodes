terraform { 
  required_providers {
    aws = "~>3.0"
  }
}


resource "aws_eks_cluster" "k8s_control_plane" {
  name     = var.name
  role_arn = var.eks_role_arn
  tags = {
    Name = var.name
    GroupName = var.group_name
  }
  version = var.eks_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = false
    subnet_ids = var.subnet_ids
    security_group_ids = var.control_plane_sg
  }
}