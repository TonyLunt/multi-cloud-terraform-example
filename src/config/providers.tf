data "terraform_remote_state" "tfc" {
  backend = "remote"

  config = {
    organization = "cardinalsolutions"

    workspaces = {
      name = "multi-cloud-terraform-example"
    }
  }
}


provider "kubernetes" {
  version = "1.12.0"
  alias = "aks"
  load_config_file = "false"

  host = data.terraform.tfc.outputs.aks.host

  client_certificate     = data.terraform.tfc.outputs.aks.client_certificate
  client_key             = data.terraform.tfc.outputs.aks.client_key
  cluster_ca_certificate = data.terraform.tfc.outputs.aks.cluster_ca_certificate
}

provider "kubernetes" {
  version = "1.12.0"
  alias = "gke"
  load_config_file = "false"

  host = data.terraform.tfc.outputs.gke.host

  username = data.terraform.tfc.outputs.gke.username
  password = data.terraform.tfc.outputs.gke.password
}