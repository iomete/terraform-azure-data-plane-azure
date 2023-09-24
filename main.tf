
data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.cluster_name}-rg"
  location = var.location
  tags     = local.tags
}

locals {
  lakehouse_user_assigned_identity_name = "${var.cluster_name}-lakehouse-user-assigned-identity"

  lakehouse_bucket_name = "${var.cluster_name}-lakehouse"
  assets_bucket_name    = "${var.cluster_name}-assets"
  lakehouse_role_name   = "${var.cluster_name}-lakehouse-role"

  module_version       = "1.0.0"

  tags = {
    "iomete.com-cluster_name" : var.cluster_name
    "iomete.com-terraform" : true
    "iomete.com-managed" : true
  }
}