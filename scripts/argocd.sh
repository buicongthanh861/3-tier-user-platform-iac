#!/bin/bash
echo "ArgoCD: http://localhost:8080"
echo "Username: admin"
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
kubectl -n argocd port-forward svc/argocd-server 8080:443
