#!/usr/bin/env bash

set -e

WORKSPACE=$1
PUBLIC_IP=$2
PRIVATE_IP=$3
KEY_FILE=$4

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${KEY_FILE} root@${PUBLIC_IP}:/etc/kubernetes/admin.conf .
sed -e "s/${PRIVATE_IP}/${PUBLIC_IP}/g" admin.conf > ${WORKSPACE}.conf
rm admin.conf
