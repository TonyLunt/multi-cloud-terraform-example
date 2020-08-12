module "k8s-aks" {
    source = "./local-modules/k8s_config"
    providers = {
        kubernetes = kubernetes.aks
    }
}

module "k8s-gke" {
    source = "./local-modules/k8s_config"
    providers = {
        kubernetes = kubernetes.gke
    }
}