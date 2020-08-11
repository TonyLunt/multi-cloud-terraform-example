resource "random_id" "suffix" {
  byte_length = 2
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

}

module "gke" {
  source                      = "app.terraform.io/cardinalsolutions/kubernetes-engine/google//modules/beta-public-cluster"
  version                     = "9.2.0"
  project_id                  = local.cloud_config.gke.project_id
  name                        = "${local.common_name}${random_id.suffix.hex}"
  region                      = local.cloud_config.gke.location
  network                     = google_compute_network.main.name
  subnetwork                  = google_compute_subnetwork.main.name
  ip_range_pods               = google_compute_subnetwork.main.name
  ip_range_services           = google_compute_subnetwork.main.secondary_ip_range.range_name
  
  # Disable workload identity
  identity_namespace = null
  node_metadata      = "UNSPECIFIED"
}

resource "google_compute_network" "main" {
  name        = "demo"
  description = "demo network"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "subnet-1a"
  region        = local.cloud_config.gke.location
  ip_cidr_range = "192.168.5.0/24"
  network       = google_compute_network.main.self_link

  secondary_ip_range {
    range_name    = "subnet-1b"
    ip_cidr_range = "192.168.6.0/24"
  }
}
