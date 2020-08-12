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
         host = module.gke.endpoint
         username               = local.cloud_config.gke.username
         password               = random_password.password.result
         cluster_ca_certificate = data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate
    }
}