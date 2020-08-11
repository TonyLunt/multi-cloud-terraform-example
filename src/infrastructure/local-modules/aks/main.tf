resource "azuread_application" "aks-app" {
  count                      = (var.client_secret == null || var.client_id == null) ? 1 : 0
  name                       = "aks-${var.cluster_name}-${var.location}-app"
  homepage                   = "https://aks-${var.cluster_name}-${var.location}-app"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aks-sp" {
  count          = (var.client_secret == null || var.client_id == null) ? 1 : 0
  application_id = azuread_application.aks-app.*.application_id[0]
}

resource "azuread_service_principal_password" "aks-sp-pw" {
  count                = (var.client_secret == null || var.client_id == null) ? 1 : 0
  service_principal_id = azuread_service_principal.aks-sp.*.id[0]
  value                = random_string.aks-sp-pw.*.result[0]
  end_date_relative    = "8760h"
}

resource "random_string" "aks-sp-pw" {
  count   = (var.client_secret == null || var.client_id == null) ? 1 : 0
  length  = 44
  special = false
}

resource "azurerm_kubernetes_cluster" "module" {
  name                            = var.cluster_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = local.dns_prefix
  kubernetes_version              = var.kubernetes_version
  api_server_authorized_ip_ranges = length([var.api_server_authorized_ip_ranges]) > 0 ? var.api_server_authorized_ip_ranges : null
  enable_pod_security_policy      = var.enable_rbac ? var.enable_pod_security_policy : false
  node_resource_group             = var.node_resource_group
  private_link_enabled            = var.lb_sku == "Standard" ? var.enable_private_link : null
  tags                            = var.tags

  dynamic "identity" {
    for_each = var.enable_MSI_nodes ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  dynamic "service_principal" {
    for_each = var.enable_MSI_nodes ? [] : [1]
    content {
      client_id     = (var.client_secret == null || var.client_id == null) ? azuread_application.aks-app.*.application_id[0] : var.client_id
      client_secret = (var.client_secret == null || var.client_id == null) ? azuread_service_principal_password.aks-sp-pw.*.value[0] : var.client_secret
    }
  }

  default_node_pool {
    name                  = var.default_node_pool_name
    vm_size               = var.default_node_pool_vm_size
    availability_zones    = (var.default_node_pool_type == "VirtualMachineScaleSets" && var.lb_sku == "Standard") ? var.default_node_pool_avability_zones : null
    enable_auto_scaling   = var.default_node_pool_type == "VirtualMachineScaleSets" ? var.default_node_pool_enable_auto_scaling : false
    enable_node_public_ip = var.default_node_pool_enable_node_public_ip
    max_pods              = (var.network_plugin == "kubenet" && var.default_node_pool_max_pods > 110) ? 110 : var.default_node_pool_max_pods
    node_taints           = var.default_node_pool_node_taints
    os_disk_size_gb       = var.default_node_pool_os_disk_size_gb
    type                  = var.default_node_pool_type
    vnet_subnet_id        = var.network_plugin == "azure" ? var.default_node_pool_subnet_id : null
    max_count             = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null
    min_count             = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    node_count            = var.default_node_pool_count
  }

  # Enabled RBAC without AAD integration
  dynamic "role_based_access_control" {
    for_each = (var.enable_rbac && var.client_app_id == null && var.server_app_id == null && var.server_app_secret == null) ? [1] : []
    content {
      enabled = true
    }
  }

  # Enabled RBAC with AAD integration
  dynamic "role_based_access_control" {
    for_each = (var.enable_rbac && var.client_app_id != null && var.server_app_id != null && var.server_app_secret != null) ? [1] : []
    content {
      enabled = true

      azure_active_directory {
        client_app_id     = var.client_app_id
        server_app_id     = var.server_app_id
        server_app_secret = var.server_app_secret
        tenant_id         = var.tenant_id
      }
    }
  }

  dynamic "linux_profile" {
    for_each = var.ssh_key_data != null ? [1] : []
    content {
      admin_username = var.admin_username
      ssh_key {
        key_data = file(var.ssh_key_data)
      }
    }
  }

  dynamic "windows_profile" {
    for_each = var.admin_password != null ? [1] : []
    content {
      admin_username = var.admin_username
      admin_password = var.admin_password
    }
  }

  # basic or standard load balancer without advanced load_balancer_profile configuration options
  dynamic "network_profile" {
    for_each = (var.lb_sku == "Basic" || (var.lb_managed_outbound_ip_count == null && var.lb_ip_prefix_ids == null && var.lb_ip_address_ids == null)) ? [1] : []
    content {
      network_plugin     = var.network_plugin
      network_policy     = var.network_plugin == "azure" ? "azure" : var.network_policy
      dns_service_ip     = var.network_plugin == "azure" ? local.dns_service_ip : null
      docker_bridge_cidr = var.network_plugin == "azure" ? var.docker_bridge_cidr : null
      service_cidr       = var.network_plugin == "azure" ? var.service_cidr : null
      pod_cidr           = var.network_plugin == "kubenet" ? local.pod_cidr : null
      load_balancer_sku  = var.lb_sku
    }
  }

  # standard load balancer including the advanced load_balancer_profile configuration options
  dynamic "network_profile" {
    for_each = (var.lb_sku == "Standard" && (var.lb_managed_outbound_ip_count != null || var.lb_ip_prefix_ids != null || var.lb_ip_address_ids != null)) ? [1] : []
    content {
      network_plugin     = var.network_plugin
      network_policy     = var.network_plugin == "azure" ? "azure" : var.network_policy
      dns_service_ip     = var.network_plugin == "azure" ? local.dns_service_ip : null
      docker_bridge_cidr = var.network_plugin == "azure" ? var.docker_bridge_cidr : null
      service_cidr       = var.network_plugin == "azure" ? var.service_cidr : null
      pod_cidr           = var.network_plugin == "kubenet" ? local.pod_cidr : null
      load_balancer_sku  = var.lb_sku

      load_balancer_profile {
        managed_outbound_ip_count = var.lb_managed_outbound_ip_count
        outbound_ip_prefix_ids    = var.lb_ip_prefix_ids
        outbound_ip_address_ids   = var.lb_ip_address_ids
      }
    }
  }

  addon_profile {
    aci_connector_linux {
      enabled     = var.enable_aci_connector
      subnet_name = var.enable_aci_connector ? var.aci_subnet_name : null
    }

    azure_policy {
      enabled = var.enable_azure_policy
    }

    # This forces a rebuild and setting null as default here is not effective in preventing a rebuild.  
    # This is being left as a comment intentionally as a reminder to add it back in once we are ready for a cluster rebuild.
    # http_application_routing {
    #   enabled = var.enable_http_application_routing
    # }

    kube_dashboard {
      enabled = var.enable_kube_dashboard
    }

    oms_agent {
      enabled                    = var.enable_oms
      log_analytics_workspace_id = var.enable_oms ? var.log_analytics_workspace_id : null
    }
  }
}
