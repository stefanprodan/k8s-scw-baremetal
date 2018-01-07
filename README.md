# k8s-scw-arm

Kubernetes installer for Scaleway Baremetal ARM and AMD64

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

Create an ARMv7 bare-metal Kubernetes cluster with one master and two nodes:

```bash
$ terraform workspace new arm

$ terraform apply \
 -var region=par1 \
 -var arch=arm \
 -var server_type=C1 \
 -var nodes=2 \
 -var weave_passwd=ChangeMe \
 -var k8s_version=stable-1.9 \
 -var docker_version=17.03.0~ce-0~ubuntu-xenial
```

This will do the following:

* reserves public IPs for each server
* provisions three bare-metal servers with Ubuntu 16.04.1 LTS
* connects to the master server via SSH and installs Docker CE and kubeadm armhf apt packages
* runs kubeadm init on the master server and configures kubectl
* downloads the kubectl admin config file on your local machine and replaces the private IP with the public one
* creates a Kubernetes secret with the Weave Net password
* installs Weave Net with encrypted overlay
* installs Kubernetes dashboard
* starts the worker nodes in parallel and installs Docker CE and kubeadm
* joins the worker nodes in the cluster using the kubeadm token obtained from the master

Scale up by increasing the number of nodes:

```bash
$ terraform apply \
 -var nodes=3 
```

Tear down the whole infrastructure with:

 ```bash
terraform destroy -force
```

Create an AMD64 bare-metal Kubernetes cluster with one master and a nodes:

```bash
$ terraform workspace new amd64

$ terraform apply \
 -var region=par1 \
 -var arch=x86_64 \
 -var server_type=C2S \
 -var nodes=1 \
 -var weave_passwd=ChangeMe \
 -var k8s_version=stable-1.9 \
 -var docker_version=17.03.0~ce-0~ubuntu-xenial
```

### Remote control

After applying the Terraform plan you'll see several output variables like the master public IP, 
the kubeadmn join command and the current workspace admin config. 

In order to run `kubectl` commands against the Scaleway cluster you can use the `kubectl_config` output variable:

```bash
kubectl --kubeconfig ./$(terraform output kubectl_config) get nodes
```

In order to access the dashboard you'll need to find its cluster IP:

```bash
$ kubectl --kubeconfig ./arm.conf -n kube-system get svc --selector=k8s-app=kubernetes-dashboard
  NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
  kubernetes-dashboard   ClusterIP   10.110.164.164   <none>        80/TCP    38m
```

Open a SSH tunnel:

```bash
ssh -L 8888:<CLUSTER_IP>:80 root@<MASTER_PUBLIC_IP>
```

Now you can access the dashboard on your computer at `http://localhost:8888`.
