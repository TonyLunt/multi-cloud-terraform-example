resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.location

  master_auth {
    username = "foo"
    password = "1234abcd1234abcd"

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  version    = var.kubernetes_version
  project    = var.project

  node_config {
    preemptible  = true
    machine_type = var.node_size

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}