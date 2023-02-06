resource "null_resource" "k8s_access_setup" {
  count = var.active ? 1 : 0
  triggers = {
    k8s_config_raw = var.k8s_config_raw
    generated_yaml = templatefile("${path.module}/k8s-access.tpl", {
      CLUSTER_ACCESS_ROLE=var.cluster_access_role
      USERNAME=split("/",var.cluster_access_role)[1]
      })
    exec_file = filemd5("${path.module}/run.sh")
  }

  provisioner "local-exec" {
     interpreter = ["bash", "-c"]
     command = "${path.module}/run.sh \"${self.triggers.generated_yaml}\" \"${self.triggers.k8s_config_raw}\""
  }
}