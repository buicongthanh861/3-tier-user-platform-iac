#!/bin/bash
echo "Installing NGINX Ingress..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    -n ingress-nginx --create-namespace \
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30080
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
