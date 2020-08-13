resource "random_id" "suffix" {
  byte_length = 2
}

resource "random_password" "password" {
  length  = 24
  special = false
}

resource "azurerm_resource_group" "aks" {
  name     = local.common_name
  location = local.cloud_config.aks.location
}

module "aks" {
  source                      = "./local-modules/aks"
  cluster_name                = "${local.common_name}${random_id.suffix.hex}"
  kubernetes_version          = local.common_k8s_config.version
  location                    = local.cloud_config.aks.location
  resource_group_name         = azurerm_resource_group.aks.name
  default_node_pool_vm_size   = "Standard_B2ms"
  default_node_pool_count     = local.common_k8s_config.node_count
  default_node_pool_subnet_id = null
  network_plugin              = "kubenet"
  network_policy              = "calico"
  enable_rbac                 = false
  enable_oms                  = false
  tags                        = { foo = "helloworld" }
}

module "gke" {
  source                   = "app.terraform.io/cardinalsolutions/kubernetes-engine/google//modules/beta-public-cluster"
  version                  = "9.2.0"
  project_id               = local.cloud_config.gke.project_id
  name                     = "${local.common_name}${random_id.suffix.hex}"
  region                   = local.cloud_config.gke.location
  network                  = "default"
  subnetwork               = "default"
  issue_client_certificate = true
  ip_range_pods            = ""
  ip_range_services        = ""
  skip_provisioners        = true
  basic_auth_username      = local.cloud_config.gke.username
  basic_auth_password      = random_password.password.result
  # Disable workload identity
  identity_namespace = null
  node_metadata      = "UNSPECIFIED"
}

data "google_container_cluster" "gke" {
  name     = module.gke.name
  location = module.gke.location
}
