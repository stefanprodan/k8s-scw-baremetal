#!/usr/bin/env bash

set -e

ARCH=$1

kubectl apply -f /tmp/dashboard-admin.yaml

if [ "$ARCH" == "arm" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard-arm.yaml;
elif [ "$ARCH" == "x86_64" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml;
fi


