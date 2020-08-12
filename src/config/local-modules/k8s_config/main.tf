resource "kubernetes_namespace" "main" {
  metadata {
    name = "master2020"
  }
}