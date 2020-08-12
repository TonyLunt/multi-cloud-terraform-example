locals {
  common_name = "tonylunt"
  common_k8s_config = {
    node_count = 1
    version    = "1.17.9"
  }

  cloud_config = {
    aks = {
      location = "eastus2"
    }
    gke = {
      location   = "us-east1"
      project_id = "tony-lunt"
      username   = "tonylunt"
    }
  }
}