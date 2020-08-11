provider "azurerm" {
  version = "2.22.0"
  features {}
}

provider "azuread" {
  version = "0.11.0"
}

provider "random" {
  version = "2.3.0"
}

provider "google" {
  version = "3.33.0"
  project = "tony-lunt"
}