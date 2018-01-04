variable "docker_version" {
  default = "17.03.0~ce-0~ubuntu-xenial"
}

variable "k8s_version" {
  default = "stable-1.9"
}

variable "weave_passwd" {
  default = "ChangeMe"
}

variable "region" {
  default = "par1"
}

variable "instance_type" {
  default = "C1"
}

variable "nodes" {
  default = 1
}
