variable "docker_version" {
  default     = "17.03.0~ce-0~ubuntu-xenial"
  description = "Use 17.12.0~ce-0~ubuntu for arm64"
}

variable "k8s_version" {
  default = "stable-1.9"
}

variable "weave_passwd" {
  default = "ChangeMe"
}

variable "arch" {
  default     = "arm"
  description = "Values: arm arm64 x86_64"
}

variable "region" {
  default = "par1"
}

variable "server_type" {
  default     = "C1"
  description = "Use C1 for arm, ARM64-2GB for arm64 and C2S for x86_64"
}

variable "nodes" {
  default = 2
}
