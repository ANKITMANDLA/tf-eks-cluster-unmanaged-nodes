provider "aws" {
  version = "~>3.0"
}


#refer to  modules/eks-security/
# 2 common sg

#control plane common
#ingress rule 443 vpn networks / office networks (to access kubectl api)