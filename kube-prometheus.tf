provider "helm" {
  kubernetes {
    config_path = "./${module.eks.kubeconfig_filename}"
  }
}

resource "helm_release" "kube_prometheus" {
  lint = "true"

  name = "kube-prometheus"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "13.13.0"

  namespace        = "monitoring"
  create_namespace = true

  timeout          = 600
  wait             = true

  # Tweaked helm values for running on EKS
  values = [
    file("values-kube-prometheus.yaml")
  ]
}
