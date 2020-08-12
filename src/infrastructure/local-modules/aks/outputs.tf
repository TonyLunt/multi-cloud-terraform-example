output "id" {
  description = "The Azure AKS managed cluster ID."
  value       = azurerm_kubernetes_cluster.module.id
}

output "fqdn" {
  description = "The fully-qualified domain name of the Azure AKS cluster."
  value       = azurerm_kubernetes_cluster.module.fqdn
}

output "private_fqdn" {
  description = "The fully-qualified domain name for the Kubernetes Cluster when private link has been enabled. This FQDN will only be resolvable inside the Virtual Network used by the Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.module.private_fqdn
}

output "kube_admin_config" {
  description = "The kube_admin_config block. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config : null
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config_raw : null
  sensitive   = true
}

output "kube_config" {
  description = "A kube_config block."
  value       = azurerm_kubernetes_cluster.module.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "Raw Kubernetes config to be used by kubectl and other compatible tools"
  value       = azurerm_kubernetes_cluster.module.kube_config_raw
  sensitive   = true
}

# output "http_application_routing" {
#   description = "The Zone Name of the HTTP Application Routing."
#   value       = azurerm_kubernetes_cluster.module.http_application_routing
# }

output "node_resource_group" {
  description = "The name of the Azure Resource Group which contains the resources for this Managed Kubernetes Cluster."
  value       = azurerm_kubernetes_cluster.module.node_resource_group
}

# kube_admin_config
output "admin_client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config.0.client_key : null
  sensitive   = true
}


output "admin_client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config.0.client_certificate : null
}


output "admin_cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config.0.cluster_ca_certificate : null
}

output "admin_username" {
  description = "A username used to authenticate to the Kubernetes cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config.0.username : null
}


output "admin_password" {
  description = "A password or token used to authenticate to the Kubernetes cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = var.enable_rbac ? azurerm_kubernetes_cluster.module.kube_admin_config.0.password : null
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded private key used by clients to authenticate to the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.module.kube_config.0.client_key
}


output "client_certificate" {
  description = "Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.module.kube_config.0.client_certificate
}


output "cluster_ca_certificate" {
  description = "Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster."
  value       = azurerm_kubernetes_cluster.module.kube_config.0.cluster_ca_certificate
}


output "host" {
  description = "The Kubernetes cluster server host."
  value       = azurerm_kubernetes_cluster.module.kube_config.0.host
}


# output "username" {
#   description = "A username used to authenticate to the Kubernetes cluster."
#   value       = azurerm_kubernetes_cluster.kube_config.module.username
# }


# output "password" {
#   description = "A password or token used to authenticate to the Kubernetes cluster."
#   value       = azurerm_kubernetes_cluster.kube_config.module.password
# }

output "effective_outbound_ips" {
  description = "Public IPs assigned for outbound traffic through the standard load balancer. Does not apply with a Basic LB SKU"
  value       = (length(azurerm_kubernetes_cluster.module.network_profile.0.load_balancer_profile) > 0) ? azurerm_kubernetes_cluster.module.network_profile.0.load_balancer_profile.0.effective_outbound_ips : null
}


output "identity" {
  description = "AKS Identity id (either user assigned or MSI)"
  value       = azurerm_kubernetes_cluster.module.identity
}