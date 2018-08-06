provider "scaleway" {
  region  = "${var.region}"
  version = "1.5.1"
}

provider "external" {
  version = "1.0.0"
}

data "scaleway_image" "xenial" {
  architecture = "${var.arch}"
  name         = "Ubuntu Xenial"
}
