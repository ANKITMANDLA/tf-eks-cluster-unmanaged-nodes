locals {
  vpc_id = "vpc-XXXXX"
  subnet_ids = ["subnet-X","subnet-XX","subnet-XXX"]
  eks_name = "${var.custom_domain}-eks"
  eks_version = "1.18"
  eks_standard_worker_group_name = "${local.eks_name}-standard-worker-group"
  eks_standard_worker_group_disk_size = 25
  eks_standard_worker_group_type = "m5a.xlarge"
  eks_standard_worker_node_count = 3
  eks_role_arn = "arn:aws:iam::XX:role/example-eks-cluster" #iam role for eks control plane
  additional_control_plane_sg_ids = ["sg-XX"]
  additional_worker_nodes_sg_ids = ["sg-XX"]
  eks_worker_node_ami_image_id = "ami-XX"
  eks_worker_node_instance_role = "arn:aws:iam::XX:role/example-eks-node-instance"
  eks_worker_node_ssh_key_name = "vm-ssh-key"
  cluster_access_role = "arn:aws:iam::xx:role/example-eks-cluster"
  kube_config_store_bucket = "example-prov-vm-kube-config"
}

module "eks_security" {
  source = "../../../modules/k8s/eks-security"

  eks_cluster_name = local.eks_name
  vpc_id           = local.vpc_id
  group_name       = var.custom_domain
}

module "example_security" {
  source = "../../../modules/common-sg"

  eks_cluster_name = local.eks_name
  vpc_id           = local.vpc_id
  group_name       = var.custom_domain
  worker_grp_sg_id = module.ks_security.worker_node_sg_id
}

module "eks_control_plane" {
  source = "../../../modules/k8s/eks-control-plane"
  
  group_name       = var.custom_domain
  control_plane_sg = concat([module.eks_security.control_plane_sg_id],[module.example_security.example-common-sg-id], local.additional_control_plane_sg_ids)
  name             = local.eks_name
  subnet_ids       = local.subnet_ids
  eks_version      = local.eks_version
  eks_role_arn     = local.eks_role_arn
}


module "worker_node_group" {
  source = "../../../modules/k8s/eks-worker-node"
  
  eks_cluster_name    = module.eks_control_plane.name
  name                = local.eks_standard_worker_group_name
  group_name          = var.custom_domain
  disk_size           = local.eks_standard_worker_group_disk_size
  instance_type       = local.eks_standard_worker_group_type
  subnet_ids          = local.subnet_ids
  node_count          = local.eks_standard_worker_node_count
  worker_sg           = concat([module.eks_security.worker_node_sg_id],[module.example_security.example-common-sg-id], local.additional_control_plane_sg_ids) 
  ami_image_id        = local.eks_worker_node_ami_image_id
  node_instance_role  = local.eks_worker_node_instance_role
  ssh_key_name        = local.eks_worker_node_ssh_key_name
  active              = var.active
}

module "eks_kubeconfig" {
  source = "../../../modules/k8s/eks-kubeconfig"

  eks_cluster_name         = module.eks_control_plane.name
  cluster_access_role      = local.cluster_access_role
  kube_config_store_bucket = local.kube_config_store_bucket
}


