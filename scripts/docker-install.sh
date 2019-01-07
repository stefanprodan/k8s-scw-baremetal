#!/usr/bin/env bash

set -e

UBUNTU_VERSION=$1
ARCH=$2
DOCKER_VERSION=$3

if [[ ${ARCH} == "arm" ]]; then export ARCH=armhf; fi
if [[ ${ARCH} == "x86_64" ]]; then export ARCH=amd64; fi

apt-get update -qq
apt-get install -y -qq apt-transport-https ca-certificates curl git
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq -
echo "deb [arch=${ARCH}] https://download.docker.com/linux/ubuntu ${UBUNTU_VERSION} stable" | \
  tee /etc/apt/sources.list.d/docker.list
apt-get update -qq

if (( $(echo -n ${DOCKER_VERSION} | wc -c) > 5 )); then
  export EXACT_DOCKER_VERSION=${DOCKER_VERSION}
else
  export EXACT_DOCKER_VERSION=$(apt-cache madison docker-ce | \
    grep "${DOCKER_VERSION}.*${UBUNTU_VERSION}" | awk 'NR==1 {print $3}')
fi

apt-get install -y -qq --no-install-recommends docker-ce=${EXACT_DOCKER_VERSION}
apt-mark hold docker-ce
docker version

