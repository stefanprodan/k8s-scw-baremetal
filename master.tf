resource "scaleway_ip" "k8s_master_ip" {
  count = 1
}

resource "scaleway_server" "k8s_master" {
  count     = 1
  name      = "k8s-master-${count.index + 1}"
  image     = "${data.scaleway_image.xenial.id}"
  type      = "${var.instance_type}"
  public_ip = "${element(scaleway_ip.k8s_master_ip.*.ip, count.index)}"

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
      "kubeadm init --apiserver-advertise-address=${self.private_ip} --kubernetes-version ${var.k8s_version}",
      "mkdir -p $HOME/.kube && cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "kubectl apply -f \"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')\"",
    ]
  }
}

data "external" "kubeadm_join" {
  program = ["./scripts/kubeadm-token.sh"]

  query = {
    host = "${scaleway_ip.k8s_master_ip.0.ip}"
  }

  depends_on = ["scaleway_server.k8s_master"]
}
