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

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }

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
        type: LoadBalancer
    configs:
      params:
        server.insecure: "true"
    EOT
  ]
}

# resource "helm_release" "prometheus_stack" {
#   name       = "kube-prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   version    = "68.1.1"
#   namespace  = kubernetes_namespace.monitoring.metadata[0].name
#   create_namespace = true

#   depends_on = [aws_eks_node_group.general]

#   values = [
#     <<-EOT
#     grafana:
#       service:
#         type: LoadBalancer
#       adminPassword: "admin123"
#       persistence:
#         enabled: false

#     prometheus:
#       service:
#         type: LoadBalancer
#     EOT
#   ]
# }
