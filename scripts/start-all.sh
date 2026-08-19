#!/bin/bash
set -e

aws eks update-kubeconfig --region ap-southeast-1 --name staging-demo-eks 
echo "=== Installing NGINX Ingress ==="
./nginx.sh

echo "=== Starting port-forwards in background ==="
./argocd.sh > /tmp/argocd.log 2>&1 &
echo "ArgoCD PID: $!"

./grafana.sh > /tmp/grafana.log 2>&1 &
echo "Grafana PID: $!"

./prometheus.sh > /tmp/prometheus.log 2>&1 &
echo "Prometheus PID: $!"

echo ""
echo "Đã khởi động xong. Xem log tại /tmp/*.log"
echo "Dừng tất cả: pkill -f 'port-forward'"

wait
