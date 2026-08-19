#!/bin/bash
echo "Grafana: http://localhost:3000"
echo "Username: admin"
echo "Password: admin123"
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
