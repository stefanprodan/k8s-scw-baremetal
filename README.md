# k8s-scw-baremetal

Kubernetes Terraform installer for Scaleway bare-metal ARM and AMD64

### Initial setup

Clone the repository and install the dependencies:

```bash
$ git clone https://github.com/stefanprodan/k8s-scw-baremetal.git
$ cd k8s-scw-baremetal
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
* installs cluster add-ons (Kubernetes dashboard, metrics server and Heapster)
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

Create an AMD64 bare-metal Kubernetes cluster with one master and a node:

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

Check if Heapster works: 

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  top nodes

NAME           CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%   
arm-master-1   655m         16%       873Mi           45%       
arm-node-1     147m         3%        618Mi           32%       
arm-node-2     101m         2%        584Mi           30% 
```

The `kubectl` config file format is `<WORKSPACE>.conf` as in `arm.conf` or `amd64.conf`.

In order to access the dashboard you'll need to find its cluster IP:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  -n kube-system get svc --selector=k8s-app=kubernetes-dashboard

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes-dashboard   ClusterIP   10.107.37.220   <none>        80/TCP    6m
```

Open a SSH tunnel:

```bash
ssh -L 8888:<CLUSTER_IP>:80 root@<MASTER_PUBLIC_IP>
```

Now you can access the dashboard on your computer at `http://localhost:8888`.

![Overview](https://github.com/stefanprodan/scw-arm/blob/master/screens/dash-overview.jpg)

![Nodes](https://github.com/stefanprodan/scw-arm/blob/master/screens/dash-nodes.jpg)

### Expose services outside the cluster

Since we're running on bare-metal and Scaleway doesn't offer a load balancer, the easiest way to expose 
applications outside of Kubernetes is using a NodePort service. 

Let's deploy the [podinfo](https://github.com/stefanprodan/k8s-podinfo) app in the default namespace. 
Podinfo has a multi-arch Docker image and it will work on arm, arm64 or amd64.

Create the podinfo nodeport service:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  apply -f https://raw.githubusercontent.com/stefanprodan/k8s-podinfo/master/deploy/podinfo-svc-nodeport.yaml

service "podinfo-nodeport" created
```

Create the podinfo deployment:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  apply -f https://raw.githubusercontent.com/stefanprodan/k8s-podinfo/master/deploy/podinfo-dep.yaml

deployment "podinfo" created
```

Inspect the podinfo service to obtain the port number:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  get svc --selector=app=podinfo

NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
podinfo-nodeport   NodePort   10.104.132.14   <none>        9898:31190/TCP   3m
```

You can access podinfo at `http://<MASTER_PUBLIC_IP>:31190` or using curl:

```bash
$ curl http://$(terraform output k8s_master_public_ip):31190

runtime:
  arch: arm
  max_procs: "4"
  num_cpu: "4"
  num_goroutine: "12"
  os: linux
  version: go1.9.2
labels:
  app: podinfo
  pod-template-hash: "1847780700"
annotations:
  kubernetes.io/config.seen: 2018-01-08T00:39:45.580597397Z
  kubernetes.io/config.source: api
environment:
  HOME: /root
  HOSTNAME: podinfo-5d8ccd4c44-zrczc
  KUBERNETES_PORT: tcp://10.96.0.1:443
  KUBERNETES_PORT_443_TCP: tcp://10.96.0.1:443
  KUBERNETES_PORT_443_TCP_ADDR: 10.96.0.1
  KUBERNETES_PORT_443_TCP_PORT: "443"
  KUBERNETES_PORT_443_TCP_PROTO: tcp
  KUBERNETES_SERVICE_HOST: 10.96.0.1
  KUBERNETES_SERVICE_PORT: "443"
  KUBERNETES_SERVICE_PORT_HTTPS: "443"
  PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
externalIP:
  IPv4: 163.172.139.112
```

### Horizontal Pod Autoscaling

Starting from Kubernetes 1.9 `kube-controller-manager` is configured by default with
`horizontal-pod-autoscaler-use-rest-clients`. 
In order to use HPA we need to install the metrics server to enable the new metrics API used by HPA v2. 
Both Heapster and the metrics server have been deployed from Terraform 
when the master node was provisioned.

The metric server collects resource usage data from each node using Kubelet Summary API. 
Check if the metrics server is running:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
 get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq
```
```json
  {
    "kind": "NodeMetricsList",
    "apiVersion": "metrics.k8s.io/v1beta1",
    "metadata": {
      "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes"
    },
    "items": [
      {
        "metadata": {
          "name": "arm-master-1",
          "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/arm-master-1",
          "creationTimestamp": "2018-01-08T15:17:09Z"
        },
        "timestamp": "2018-01-08T15:17:00Z",
        "window": "1m0s",
        "usage": {
          "cpu": "384m",
          "memory": "935792Ki"
        }
      },
      {
        "metadata": {
          "name": "arm-node-1",
          "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/arm-node-1",
          "creationTimestamp": "2018-01-08T15:17:09Z"
        },
        "timestamp": "2018-01-08T15:17:00Z",
        "window": "1m0s",
        "usage": {
          "cpu": "130m",
          "memory": "649020Ki"
        }
      },
      {
        "metadata": {
          "name": "arm-node-2",
          "selfLink": "/apis/metrics.k8s.io/v1beta1/nodes/arm-node-2",
          "creationTimestamp": "2018-01-08T15:17:09Z"
        },
        "timestamp": "2018-01-08T15:17:00Z",
        "window": "1m0s",
        "usage": {
          "cpu": "120m",
          "memory": "614180Ki"
        }
      }
    ]
  }
```

Let's define a HPA that will maintain a minimum of two replicas and will scale up to ten 
if the CPU average is over 80% or if the memory goes over 200Mi.

```yaml
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: podinfo
spec:
  scaleTargetRef:
    apiVersion: apps/v1beta1
    kind: Deployment
    name: podinfo
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      targetAverageUtilization: 80
  - type: Resource
    resource:
      name: memory
      targetAverageValue: 200Mi
```

Apply the podinfo HPA:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) \
  apply -f https://raw.githubusercontent.com/stefanprodan/k8s-podinfo/master/deploy/podinfo-hpa.yaml

horizontalpodautoscaler "podinfo" created
```

After a couple of seconds the HPA controller will contact the metrics server and will fetch the CPU 
and memory usage:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) get hpa

NAME      REFERENCE            TARGETS                      MINPODS   MAXPODS   REPLICAS   AGE
podinfo   Deployment/podinfo   2826240 / 200Mi, 15% / 80%   2         10        2          5m
```

In order to increase the CPU usage we could run a load test with hey:

```bash
#install hey
go get -u github.com/rakyll/hey

#do 10K requests rate limited at 20 QPS
hey -n 10000 -q 10 -c 5 http://$(terraform output k8s_master_public_ip):31190
```

You can monitor the autoscaler events with:

```bash
$ kubectl --kubeconfig ./$(terraform output kubectl_config) describe hpa

Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  7m    horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  3m    horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization (percentage of request) above target
```

After the load tests finishes the autoscaler will remove replicas until the deployment reaches the initial replica count:

```
Events:
  Type    Reason             Age   From                       Message
  ----    ------             ----  ----                       -------
  Normal  SuccessfulRescale  20m   horizontal-pod-autoscaler  New size: 4; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  16m   horizontal-pod-autoscaler  New size: 8; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  12m   horizontal-pod-autoscaler  New size: 10; reason: cpu resource utilization (percentage of request) above target
  Normal  SuccessfulRescale  6m    horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
```
