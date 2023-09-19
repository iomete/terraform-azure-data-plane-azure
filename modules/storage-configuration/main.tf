locals {

  tags = {
    "iomete.com-terraform" : true
    "iomete.com-managed" : true
  }
}

# data "azurerm_storage_account" "existing" {
#   name                = var.storage_account_name
#   resource_group_name = var.resource_group_name
# }

resource "random_id" "strg_random" {
  byte_length = 5
}
resource "azurerm_user_assigned_identity" "workspace_user_identity" {
  name                = "iom-workspaceID-${random_id.strg_random.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}



# resource "azurerm_federated_identity_credential" "spark-credential" {
#   name                = "workspaceID-spark-credential"
#   resource_group_name = var.resource_group_name
#   audience            = ["api://AzureADTokenExchange"]
#   issuer              = var.issuer_url
#   parent_id           = azurerm_user_assigned_identity.workspace_user_identity.id
#   subject             = "system:serviceaccount:${var.workspace_id}:spark-service-account"
# }


resource "azurerm_storage_account" "module_strg_acct" {
  name                     = "iomdataplane${random_id.strg_random.hex}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
 #is_hns_enabled           = true
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}


# resource "azurerm_storage_data_lake_gen2_filesystem" "lakehouse" {
#   name                 = "lakehouse${random_id.strg_random.hex}"
#   storage_account_id   = azurerm_storage_account.module_strg_acct.id
#   depends_on = [
#     azurerm_storage_account.module_strg_acct
#   ] 
# }

resource "azurerm_storage_container" "main" {
  name                  = "${azurerm_storage_account.module_strg_acct.name}-lakehouse"
  storage_account_name  = azurerm_storage_account.module_strg_acct.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "lakehouse_storage_access" {
  scope                = azurerm_storage_account.module_strg_acct.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.workspace_user_identity.principal_id
}


resource "azurerm_role_assignment" "lakehouse_assets_access" {
  scope                = var.main_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.workspace_user_identity.principal_id

}

 

