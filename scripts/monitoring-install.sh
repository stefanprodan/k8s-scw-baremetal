#!/usr/bin/env bash

set -e

ARCH=$1

kubectl apply -f /tmp/dashboard-rbac.yaml
kubectl apply -f /tmp/heapster-rbac.yaml
kubectl apply -f /tmp/metrics-server-rbac.yaml

if [ "$ARCH" == "arm" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard-arm.yaml;
    kubectl apply -f /tmp/heapster-arm.yaml;
    kubectl apply -f /tmp/metrics-server-arm.yaml;
elif [ "$ARCH" == "x86_64" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/alternative/kubernetes-dashboard.yaml;
    kubectl apply -f /tmp/heapster-amd64.yaml;
    kubectl apply -f /tmp/metrics-server-amd64.yaml;
fi
