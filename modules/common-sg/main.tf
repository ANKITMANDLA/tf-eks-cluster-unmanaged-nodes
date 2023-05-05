terraform { 
  required_providers {
    aws = "~>3.0"
  }
}

resource "aws_security_group" "common-sg" {
  name        = "example-common-SG"
  description = "Cluster Communication with Hansen Azure network and VPN"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "example-common-sg"
    GroupName = var.group_name
  }
}

resource "aws_security_group" "elb-common-sg" {
  name        = "example-common-lb-SG"
  description = "AWS Loadbalacer inbound/outbound from Hansen Network"
  vpc_id      = var.vpc_id

  tags = {
    Name      = "example-coomon-sg"
    GroupName = var.group_name
  }
}


resource "aws_security_group_rule" "example_ingress_rule_1" {
  description       = "ingress from VPN and Office"
  security_group_id = aws_security_group.common-sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["10.0.0.0/17", "10.10.220.0/23"]
  protocol          = "tcp"
}

resource "aws_security_group_rule" "example_ingress_rul_2" {
  description       = "SSH access from VPN and Office"
  security_group_id = aws_security_group.common-sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["10.0.0.0/17", "10.10.220.0/23"]
  protocol          = "tcp"
}

resource "aws_security_group_rule" "example_ingress_rule_3" {
  description       = "ingress from Azure"
  security_group_id = aws_security_group.common-sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["10.136.32.0/20", "10.136.64.0/20","10.136.96.0/20"]
  protocol          = "tcp"
}

resource "aws_security_group_rule" "eks_egress_rule_1" {
  description       = "docker and OS packges"
  security_group_id = aws_security_group.common-sg.id
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "eks_egress_rule_2" {
  description       = "docker and OS packges"
  security_group_id = aws_security_group.common-sg.id
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_common_ingress_rule" {
  description       = "inbound from office and vpn"
  security_group_id = aws_security_group.elb-common-sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["10.0.0.0/17", "10.10.220.0/23"]
  protocol          = "tcp"
}

resource "aws_security_group_rule" "elb_common_egress_rule_1" {
  description              = "to worker nodes"
  security_group_id        = aws_security_group.elb-common-sg.id
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  source_security_group_id = var.worker_grp_sg_id
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "elb_common_egress_rule_2" {
  description              = "to cogneto"
  security_group_id        = aws_security_group.elb-common-sg.id
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  cidr_blocks              = ["0.0.0.0/0"]
  protocol                 = "tcp"
}
