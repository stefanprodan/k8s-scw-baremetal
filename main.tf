provider "scaleway" {
  region = "${var.region}"
}

data "scaleway_image" "xenial" {
  architecture = "${var.arch}"
  name         = "Ubuntu Xenial"
}
