resource "scaleway_ip" "k8s_node_ip" {
  count = "${var.nodes}"
}

resource "scaleway_server" "k8s_node" {
  count          = "${var.nodes}"
  name           = "${terraform.workspace}-node-${count.index + 1}"
  image          = "${data.scaleway_image.xenial.id}"
  type           = "${var.server_type_node}"
  public_ip      = "${element(scaleway_ip.k8s_node_ip.*.ip, count.index)}"
  security_group = "${scaleway_security_group.node_security_group.id}"

  //  volume {
  //    size_in_gb = 50
  //    type       = "l_ssd"
  //  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file("~/.ssh/id_rsa")}"
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
      "chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh ${var.docker_version}",
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh",
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
