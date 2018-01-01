resource "scaleway_ip" "k8s_node_ip" {
  count = "${var.node_instance_count}"
}

resource "scaleway_server" "k8s_node" {
  count     = "${var.node_instance_count}"
  name      = "k8s-node-${count.index + 1}"
  image     = "${data.scaleway_image.xenial.id}"
  type      = "${var.instance_type}"
  public_ip = "${element(scaleway_ip.k8s_node_ip.*.ip, count.index)}"

  connection {
    type = "ssh"
    user = "root"
  }

  provisioner "file" {
    source      = "scripts/kubeadm-install.sh"
    destination = "/tmp/kubeadm-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubeadm-install.sh && /tmp/kubeadm-install.sh",
      "${data.external.kubeadm_join.result.command}",
    ]
  }
}
