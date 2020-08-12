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
  version          = "1.12.0"
  alias            = "aks"
  load_config_file = "false"

  host = data.terraform_remote_state.tfc.outputs.aks.host

  client_certificate     = base64decode(data.terraform_remote_state.tfc.outputs.aks.client_certificate)
  client_key             = base64decode(data.terraform_remote_state.tfc.outputs.aks.client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.tfc.outputs.aks.cluster_ca_certificate)
}

provider "kubernetes" {
  version          = "1.12.0"
  alias            = "gke"
  load_config_file = "false"

  host = "https://${ data.terraform_remote_state.tfc.outputs.gke.host }

  username = data.terraform_remote_state.tfc.outputs.gke.username
  password = data.terraform_remote_state.tfc.outputs.gke.password
}