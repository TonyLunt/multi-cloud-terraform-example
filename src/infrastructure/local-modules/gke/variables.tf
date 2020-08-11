variable "cluster_name" {}

variable "location" {}

variable "node_count" {}

variable "node_size" {
    default = "e2-medium"
}

variable "kubernetes_version" {}

variable "project" {}