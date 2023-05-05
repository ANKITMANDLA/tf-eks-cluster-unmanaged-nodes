terraform { 
  required_providers {
    aws = "~>3.0"
  }
}

locals {
  ami_image_id         = "ami-0c29dd87e87fb4dfd"
  iam_instance_profile = "arn:aws:iam::893130235090:instance-profile/INSTANCEProfileRole"
  key_name             = "private-key"
}


resource "aws_autoscaling_group" "autoscaling_group" {
  count = var.active ? 1 : 0
  name                      = aws_launch_configuration.unmanaged_worker_node.name
  max_size                  = var.node_count + 2
  default_cooldown          = 300
  min_size                  = 0
  desired_capacity          = var.node_count
  launch_configuration      = aws_launch_configuration.unmanaged_worker_node.id
  vpc_zone_identifier       = var.subnet_ids

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "GroupName"
    value               = var.group_name
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_launch_configuration" "unmanaged_worker_node" {
  name_prefix                 = var.name
  image_id                    = local.ami_image_id
  instance_type               = var.instance_type
  associate_public_ip_address = false

  user_data                   = templatefile("${path.module}/user_data.tpl", {
    ClusterName = var.eks_cluster_name
    BootstrapArguments = var.bootstrap_arguments
  })

  iam_instance_profile = local.iam_instance_profile
  key_name             = local.key_name
  security_groups      = var.worker_sg

  root_block_device {
    volume_type = "gp2"
    volume_size = var.disk_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

