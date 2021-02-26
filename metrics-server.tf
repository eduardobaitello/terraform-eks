provider "kubernetes" {
  alias = "metrics-server"
  config_path = "./${module.eks.kubeconfig_filename}"
}

module "metrics_server" {
  source = "cookielab/metrics-server/kubernetes"
  version = "0.11.0"
  providers = {
    kubernetes = kubernetes.metrics-server
  }
}
