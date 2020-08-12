provider "kubernetes" {
  version = "1.12.0"
  alias = "aks"
  load_config_file = "false"

  host = var.aks.host

  client_certificate     = var.aks.client_certificate
  client_key             = var.aks.client_key
  cluster_ca_certificate = var.aks.cluster_ca_certificate
}

provider "kubernetes" {
  version = "1.12.0"
  alias = "gke"
  load_config_file = "false"

  host = var.gke.host

  client_certificate     = var.gke.client_certificate
  client_key             = var.gke.client_key
  cluster_ca_certificate = var.gke.cluster_ca_certificate
}