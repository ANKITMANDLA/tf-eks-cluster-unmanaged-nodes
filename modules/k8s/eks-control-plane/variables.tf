variable "name" {
  type = string
}

variable "group_name" {
  type = string
}

variable "eks_version" {
  type = string
}

#requires minimum of 2 different az
variable "subnet_ids" {
  type = list(string)
}

variable "control_plane_sg" {
  type = list(string)
}

variable "eks_role_arn" {
  type = string
}