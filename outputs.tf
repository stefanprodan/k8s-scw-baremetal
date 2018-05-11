output "k8s_master_public_ip" {
  value = "${scaleway_ip.k8s_master_ip.0.ip}"
}

output "kubeadm_join_command" {
  value = "${data.external.kubeadm_join.result["command"]}"
}

output "nodes_public_ip" {
  value = "${concat(scaleway_server.k8s_node.*.name, scaleway_server.k8s_node.*.public_ip)}"
}

output "kubectl_config" {
  value = "${terraform.workspace}.conf"
}
