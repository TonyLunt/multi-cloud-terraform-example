output "aks" {
    sensitive   = true
    value = {
         host = module.aks.fqdn
         client_certificate     = module.aks.client_certificate
         client_key             = module.aks.client_key
         cluster_ca_certificate = module.aks.cluster_ca_certificate
    }
}

output "gke" {
    sensitive   = true
    value = {
         host = module.gke.fqdn
         client_certificate     = data.google_container_cluster.gke.master_auth.0.client_certificate
         client_key             = data.google_container_cluster.gke.master_auth.0.client_key
         cluster_ca_certificate = data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate
    }
}