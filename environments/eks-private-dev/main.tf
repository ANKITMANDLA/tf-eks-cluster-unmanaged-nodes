provider "aws" {
  version = "~>3.0"
}

module "smp_perf_private_group" {
  source = "../../modules/infrastructure-group/eks-private-dev"
  
  custom_domain = var.custom_domain
  active        = var.active
}
