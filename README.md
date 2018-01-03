# k8s-scw-arm

Kubernetes installer for Scaleway Baremetal ARM

### Initial setup

Clone the repository and install the dependencies:

```bash
$ git clone https://github.com/stefanprodan/k8s-scw-arm.git
$ cd k8s-scw-arm
$ terraform init
```

Note that you'll need Terraform v0.10 or newer to run this project.

Before running the project you'll have to create an access token for Terraform to connect to the Scaleway API. 
Using the token and your access key, create two environment variables:

```bash
$ export SCALEWAY_ORGANIZATION="<ACCESS-KEY>"
$ export SCALEWAY_TOKEN="<ACCESS-TOKEN>" 
```

### Usage

Create a Kubernetes cluster with one master and two nodes:

```bash
terraform apply \
-var docker_version=17.03.0~ce-0~ubuntu-xenial \
-var k8s_version=stable-1.9 \
-var region=par1 \
-var instance_type=C1 \
-var nodes=2 \
-var weave_passwd=ChangeMe
```

This will do the following:

* reserves public IPs for each server
* provisions three bare-metal ARMv7 servers with Ubuntu 16.04.1 LTS
* connects to the master server via SSH and installs Docker CE and kubeadm armhf apt packages
* runs kubeadm init on the master server and configures kubectl
* creates a Kubernetes secret with the Weave Net password
* installs Weave Net with encrypted overlay
* starts the worker nodes in parallel and installs Docker CE and kubeadm
* joins the worker nodes in the cluster using the kubeadm token obtained from the master
