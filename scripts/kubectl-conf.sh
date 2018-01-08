#!/usr/bin/env bash

set -e

ARCH=$1
PUBLIC_IP=$2
PRIVATE_IP=$3

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${PUBLIC_IP}:/etc/kubernetes/admin.conf .
sed -e "s/${PRIVATE_IP}/${PUBLIC_IP}/g" admin.conf > ${ARCH}.conf
rm admin.conf
