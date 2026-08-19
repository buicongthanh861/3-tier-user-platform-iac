#!/bin/bash
aws eks update-kubeconfig --region ap-southeast-1 --name staging-demo-eks
kubectl get nodes
