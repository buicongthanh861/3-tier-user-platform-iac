data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# ============================================
# NAMESPACES
# ============================================
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# ============================================
# ARGOCD (dùng ClusterIP, không tạo LoadBalancer)
# ============================================
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.1.3"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = true

  depends_on = [aws_eks_node_group.general]

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP
      ingress:
        enabled: true
        ingressClassName: nginx
        annotations:
          nginx.ingress.kubernetes.io/ssl-redirect: "false"
          nginx.ingress.kubernetes.io/rewrite-target: /
        hosts:
          - argocd.local
    configs:
      params:
        server.insecure: "true"
    EOT
  ]
}

# ============================================
# NGINX INGRESS CONTROLLER (dùng NodePort)
# ============================================
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = kubernetes_namespace.ingress_nginx.metadata[0].name
  create_namespace = true

  depends_on = [aws_eks_node_group.general]

  values = [
    <<-EOT
    controller:
      service:
        type: NodePort
        nodePorts:
          http: 30080
          https: 30443
      resources:
        limits:
          cpu: 500m
          memory: 512Mi
        requests:
          cpu: 250m
          memory: 256Mi
    EOT
  ]
}

# ============================================
# PROMETHEUS & GRAFANA (tùy chọn)
# ============================================
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "68.1.1"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = true

  depends_on = [aws_eks_node_group.general]

  values = [
    <<-EOT
    grafana:
      service:
        type: ClusterIP
        port: 80
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - grafana.local
        annotations:
          nginx.ingress.kubernetes.io/ssl-redirect: "false"
      adminPassword: "admin123"
      persistence:
        enabled: false

    prometheus:
      service:
        type: ClusterIP
        port: 9090
      ingress:
        enabled: true
        ingressClassName: nginx
        hosts:
          - prometheus.local
        annotations:
          nginx.ingress.kubernetes.io/ssl-redirect: "false"
    EOT
  ]
}
