output "k8s_master_public_ip" {
  value = "${scaleway_ip.k8s_master_ip.0.ip}"
}

output "swarm_worker_token" {
  value = "${data.external.kubeadm_join.result.command}"
}

