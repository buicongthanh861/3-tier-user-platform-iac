./prometheus.sh

Port-forward Prometheus tới http://localhost:9090.

Lưu ý: kube-prometheus-stack hiện đang bị comment trong terraform/addons.tf, nên Prometheus/Grafana không được Terraform tự cài. Hai script này chỉ hoạt động sau khi cài thủ công:

bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
