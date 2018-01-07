#!/usr/bin/env bash

set -e

DOCKER_VERSION=$1

apt-get update -qq
apt-get install -y -qq apt-transport-https ca-certificates curl git
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq -
echo "deb https://download.docker.com/linux/ubuntu xenial stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update -qq
apt-get install -y -qq --no-install-recommends docker-ce=${DOCKER_VERSION}
apt-mark hold docker-ce

