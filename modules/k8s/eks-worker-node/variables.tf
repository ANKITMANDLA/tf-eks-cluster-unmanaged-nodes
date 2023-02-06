variable "eks_cluster_name" {
  type = string
}

variable "name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "worker_sg" {
  type = list(string)
}

variable "node_count" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "bootstrap_arguments" {
  type = string
  default = ""
}

variable "active" {
  type = bool
  default = true
}

variable "ami_image_id" {
  type = string
}

variable "node_instance_role" {
  type = string
}

variable "ssh_key_name" {
  type = string
}
