#!/bin/bash
echo "Prometheus: http://localhost:9090"
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
