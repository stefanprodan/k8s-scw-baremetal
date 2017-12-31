#!/usr/bin/env bash

set -e

# Install Docker CE
curl -fsSL get.docker.com -o get-docker.sh
CHANNEL=stable sh get-docker.sh

# Install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -q && apt-get install -qy kubeadm
apt-get install -qy git
