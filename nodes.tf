resource "scaleway_ip" "k8s_node_ip" {
  count = "${var.nodes}"
}

resource "scaleway_server" "k8s_node" {
  count          = "${var.nodes}"
  name           = "${terraform.workspace}-node-${count.index + 1}"
  image          = "${data.scaleway_image.ubuntu.id}"
  type           = "${var.server_type_node}"
  public_ip      = "${element(scaleway_ip.k8s_node_ip.*.ip, count.index)}"
  security_group = "${scaleway_security_group.node_security_group.id}"

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.private_key)}"
  }
  provisioner "file" {
    source      = "scripts/docker-install.sh"
    destination = "/tmp/docker-install.sh"
  }
  provisioner "file" {
    source      = "scripts/kubeadm-install.sh"
    destination = "/tmp/kubeadm-install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "set -e",
      "export ubuntu_version=$(echo -n ${var.ubuntu_version} | cut -d \" \" -f 2 | awk '{print tolower($0)}')",
      "chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh $${ubuntu_version} ${var.arch} ${var.docker_version}",
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh ${var.k8s_version}",
      "${data.external.kubeadm_join.result.command}",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "kubectl get pods --all-namespaces",
    ]

    on_failure = "continue"

    connection {
      type = "ssh"
      user = "root"
      host = "${scaleway_ip.k8s_master_ip.0.ip}"
    }
  }
}
