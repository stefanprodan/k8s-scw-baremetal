provider "scaleway" {
  region = "${var.region}"
}

data "scaleway_image" "xenial" {
  architecture = "arm"
  name         = "Ubuntu Xenial"
}

resource "scaleway_ip" "k8s_master_ip" {
  count = 1
}
