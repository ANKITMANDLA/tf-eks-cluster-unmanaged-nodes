resource "null_resource" "smp_bootup" {
  count = var.active ? 1 : 0
  triggers = {
    is_startup = var.active
    priority_class = "${file("${path.module}/priority-class.yaml")}"
    priority_patch = "${file("${path.module}/priority-patch.yaml")}"
  }

  provisioner "local-exec" {
     interpreter = ["bash", "-c"]
     command = "${path.module}/run.sh \"${var.k8s_config_raw}\" \"${self.triggers.priority_class}\" \"${self.triggers.priority_patch}\""
  }
}