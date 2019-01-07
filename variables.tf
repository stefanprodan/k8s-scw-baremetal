variable "ubuntu_version" {
  default = "Ubuntu Xenial"
  description = <<EOT

For arm, choose from:
  - Ubuntu Xenial

For x86_64, choose from:
  - Ubuntu Xenial
  - Ubuntu Bionic

Notes:
  - kubernetes only has xenial packages for debian
  - currently arm is not working with ubuntu bionic (kubeadm init hangs)

EOT
}

variable "docker_version" {
  default     = "18.06"
  description = <<EOT

Specify the docker version either as

  - Simplified 5 characters name such as:
    - 17.03
    - 18.06

  - The exact release name such as:
    - 17.03.0~ce-0~ubuntu-xenial
    - 18.06.0~ce~3-0~ubuntu

EOT
}

variable "k8s_version" {
  default = "stable-1.12"
}

variable "weave_passwd" {
  default = "ChangeMe"
}

variable "arch" {
  default     = "arm"
  description = "Values: arm arm64 x86_64"
}

variable "arch_bootscript" {
  default     = "4.4.127"
  description = <<EOT
Use 4.4.127 for arm and use 4.9.93 for x86_64

To view possible kernels, modify the following command as needed:

curl -sH "X-Auth-Token: <SCALEWAY_TOKEN>" -H "Content-Type: application/json" https://cp-par1.scaleway.com/images/ | \
jq '.[][] | select ( .arch == "arm" ) | select ( .name == "Ubuntu Bionic Beaver" )' | jq .default_bootscript.title
EOT
}

variable "region" {
  default     = "par1"
  description = "Values: par1 ams1"
}

variable "server_type" {
  default     = "C1"
  description = "Use C1 for arm, ARM64-2GB for arm64 and C2S for x86_64"
}

variable "server_type_node" {
  default     = "C1"
  description = "Use C1 for arm, ARM64-2GB for arm64 and C2S for x86_64"
}

variable "nodes" {
  default = 2
}

variable "ip_admin" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "IP access to services"
}

variable "private_key" {
  type        = "string"
  default     = "~/.ssh/id_rsa"
  description = "The path to your private key"
}

variable "kubeadm_verbosity" {
  default     = "0"
  description = "The verbosity level of the kubeadm init logs"
}

