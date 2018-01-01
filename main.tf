provider "scaleway" {
  region = "${var.region}"
}

data "scaleway_image" "xenial" {
  architecture = "arm"
  name         = "Ubuntu Xenial"
}

