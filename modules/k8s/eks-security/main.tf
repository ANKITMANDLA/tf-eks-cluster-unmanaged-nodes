terraform { 
  required_providers {
    aws = "~>3.0"
  }
}

resource "aws_security_group" "control_plane_security_group" {
  name        = "${var.eks_cluster_name}-control-plane"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.eks_cluster_name}-control-plane"
    GroupName = var.group_name
  }
}

resource "aws_security_group" "worker_security_group" {
  name        = "${var.eks_cluster_name}-worker"
  description = "Security group for communication between worker nodes and control"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.eks_cluster_name}-worker"
    GroupName = var.group_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "control_plane_egress" {
  description = "Outbound to eks work nodes"
  security_group_id = aws_security_group.control_plane_security_group.id
  type            = "egress"
  from_port       = 1025
  to_port         = 65535
  source_security_group_id = aws_security_group.worker_security_group.id
  protocol        = "tcp"
}

resource "aws_security_group_rule" "control_plane_ingress_1" {
  description = "Allow communication with the cluster API Server"
  security_group_id = aws_security_group.control_plane_security_group.id
  type            = "ingress"
  source_security_group_id = aws_security_group.worker_security_group.id
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
}

resource "aws_security_group_rule" "worker_egress" {
  description = "Allow communication with the cluster API Server"
  security_group_id = aws_security_group.worker_security_group.id
  type            = "egress"
  from_port       = 443
  to_port         = 443
  source_security_group_id = aws_security_group.control_plane_security_group.id
  protocol        = "tcp"
}

resource "aws_security_group_rule" "worker_ingress_for_inter_worker_node_communication" {
  description = "Allow node to communicate with each other"
  security_group_id = aws_security_group.worker_security_group.id
  type            = "ingress"
  source_security_group_id = aws_security_group.worker_security_group.id
  from_port       = -1
  to_port         = -1
  protocol        = "all"
}

resource "aws_security_group_rule" "worker_egress_for_inter_worker_node_communication" {
  description = "Allow node to communicate with each other"
  security_group_id = aws_security_group.worker_security_group.id
  type            = "egress"
  source_security_group_id = aws_security_group.worker_security_group.id
  from_port       = -1
  to_port         = -1
  protocol        = "all"
}

resource "aws_security_group_rule" "worker_ingress_from_control_plane" {
  description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  security_group_id = aws_security_group.worker_security_group.id
  type            = "ingress"
  source_security_group_id = aws_security_group.control_plane_security_group.id
  from_port       = 1025
  to_port         = 65535
  protocol        = "tcp"
}

resource "aws_security_group_rule" "worker_ingress_from_control_plane_on_443" {
  description = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  security_group_id = aws_security_group.worker_security_group.id
  type            = "ingress"
  source_security_group_id = aws_security_group.control_plane_security_group.id
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
}
