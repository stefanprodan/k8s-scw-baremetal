#!/usr/bin/env bash

set -e

ARCH=$1

kubectl apply -f /tmp/dashboard-rbac.yaml
kubectl apply -f /tmp/heapster-rbac.yaml
kubectl apply -f /tmp/metrics-server-rbac.yaml

if [ "$ARCH" == "arm" ]; then
    curl -s https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/alternative/kubernetes-dashboard-arm.yaml | \
    sed -e 's/v2.0.0-alpha0/v1.8.3/g' | \
    kubectl apply -f -;
    kubectl apply -f /tmp/heapster-arm.yaml;
    kubectl apply -f /tmp/metrics-server-arm.yaml;
elif [ "$ARCH" == "x86_64" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/alternative/kubernetes-dashboard.yaml;
    kubectl apply -f /tmp/heapster-amd64.yaml;
    kubectl apply -f /tmp/metrics-server-amd64.yaml;
fi
