provider "scaleway" {
  region  = "${var.region}"
  version = "1.8.0"
}

provider "external" {
  version = "1.0.0"
}

data "scaleway_image" "ubuntu" {
  architecture = "${var.arch}"
  name         = "${var.ubuntu_version}"
}

data "scaleway_bootscript" "architecture" {
  architecture = "${var.arch}"
  name_filter  = "${var.arch_bootscript}"
}
