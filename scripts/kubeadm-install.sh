#!/usr/bin/env bash

K8_VERSION=${1}

set -e

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq
apt-get install -qy --allow-downgrades \
  kubeadm=$(apt-cache madison kubeadm | grep $(echo ${K8_VERSION#"stable-"}) | head -1 | awk '{print $3}') \
  kubelet=$(apt-cache madison kubelet | grep $(echo ${K8_VERSION#"stable-"}) | head -1 | awk '{print $3}') \
  kubectl=$(apt-cache madison kubectl | grep $(echo ${K8_VERSION#"stable-"}) | head -1 | awk '{print $3}')
