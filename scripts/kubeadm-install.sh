#!/usr/bin/env bash

K8_VERSION=${1}

set -e

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq

declare -a deps
export deps=(kubeadm kubelet kubectl cri-tools)

for dep in "${deps[@]}"; do

  dep_version=$(echo "${dep}_version" | tr - _)
  if [[ -z "$(apt-cache madison ${dep} | grep ${K8_VERSION#"stable-"})" ]]; then
    export ${dep_version}="$(apt-cache madison "${dep}" | head -1 | awk '{print $3}')"
    echo -e """
\033[33mWarning: ${dep} version ${K8_VERSION#"stable-"}.x is not available, \
installing ${dep} $(apt-cache madison "${dep}" | head -1 | awk '{print $3}') instead\033[0m
    """ && \
    sleep 2s
  else
    export ${dep_version}="$(apt-cache madison "${dep}" | grep "${K8_VERSION#"stable-"}" | head -1 | awk '{print $3}')"
  fi

  apt-get install -qy --allow-downgrades "${dep}"="${!dep_version}"
done

