
resource "azurerm_user_assigned_identity" "assetsID" {
  name                = "${local.cluster_name}-asset-ui"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "monitoring" {
  name                = "loki-credential-managed-identity"
  resource_group_name = azurerm_resource_group.main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.assetsID.id
  subject             = "system:serviceaccount:monitoring:loki-s3access-sa"
}


resource "azurerm_storage_account" "main" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_storage_container" "assets" {
  name                  = "${local.cluster_name}-assets"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}


resource "azurerm_role_assignment" "logs_storage_access" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.assetsID.principal_id

  depends_on = [
    azurerm_storage_account.main,
  ]

}

