################################################################################
# Lakehouse User Assigned Identity
################################################################################
resource "azurerm_user_assigned_identity" "lakehouse" {
  name                = local.lakehouse_user_assigned_identity_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "lakehouse" {
  name                = local.lakehouse_user_assigned_identity_name
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.lakehouse.id
  subject             = "system:serviceaccount:iomete-system:lakehouse-service-account"
}

################################################################################
# Storage account for lakehouse
################################################################################

resource "azurerm_storage_account" "lakehouse_storage_account" {
  name                     = var.lakehouse_storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "lakehouse" {
  scope                = azurerm_storage_account.lakehouse_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.lakehouse.principal_id
}

resource "azurerm_storage_container" "lakehouse" {
  name                  = "lakehouse"
  storage_account_name  = azurerm_storage_account.lakehouse_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "assets" {
  name                  = "assets"
  storage_account_name  = azurerm_storage_account.lakehouse_storage_account.name
  container_access_type = "private"
}