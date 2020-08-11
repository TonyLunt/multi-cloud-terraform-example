# output "aks" {
#     sensitive   = true
#     value = {
#          host = module.aks.fqdn
#          client_certificate     = module.aks.admin_client_certificate
#          client_key             = module.aks.admin_client_key
#          cluster_ca_certificate = module.aks.admin_cluster_ca_certificate
#     }
# }