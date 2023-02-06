terraform { 
  required_providers {
    aws = "~>3.0"
  }
}

data "aws_eks_cluster" "k8s_control_plane" {
  name = var.eks_cluster_name
}

data "null_data_source" "kube_config_raw" {
  inputs = {
    content = templatefile("${path.module}/kube-config.tpl", {
      CLUSTER_NAME=var.eks_cluster_name
      URL=data.aws_eks_cluster.k8s_control_plane.endpoint
      CLUSTER_ACCESS_ROLE=var.cluster_access_role
      CERTIFICATE_DATA=data.aws_eks_cluster.k8s_control_plane.certificate_authority.0.data
      })
  }
}

resource "aws_s3_bucket_object" "kube_config_object" {
  bucket = var.kube_config_store_bucket
  key    = "${var.eks_cluster_name}-englan.yaml"
  content = data.null_data_source.kube_config_raw.outputs["content"]
  etag = md5(data.null_data_source.kube_config_raw.outputs["content"])
}