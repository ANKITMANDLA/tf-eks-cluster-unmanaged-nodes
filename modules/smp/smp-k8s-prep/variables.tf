variable "cluster_access_role" {
  type = string
}

variable "k8s_config_raw" {
  type = string
}

variable "active"{
  type = bool
  default = true
}
