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

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL get.docker.com -o get-docker.sh",
      "CHANNEL=stable sh get-docker.sh",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && echo \"deb http://apt.kubernetes.io/ kubernetes-xenial main\" | tee /etc/apt/sources.list.d/kubernetes.list",
      "apt-get update -q && apt-get install -qy kubeadm",
      "apt-get install -qy git",
      "kubeadm init --apiserver-advertise-address=$(hostname -I | awk '{print $1;}') --kubernetes-version ${var.k8s_version}",
      "mkdir -p $HOME/.kube",
      "cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f \"https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')\"",
    ]
  }
}
