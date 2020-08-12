locals {
    k8s_cluster = {
        gke = {
            provideralias = "kubernetes.gke"
            value = var.gke
        }
        aks = {
            provideralias = "kubernetes.aks"
            value = var.aks
        }
    }
}