# IOMETE Data-Plane, Storage configuration mmodule

 
## Usage example
 
```hcl

module "data-plane-azure_storage-configuration" {
  source                      = "iomete/data-plane-azure/azure//modules/storage-configuration"
  version                     = "1.0.0"
  issuer_url                  = var.issuer_url
  resource_group_name         = var.resource_group_name
  location                    = var.location
  cluster_name                = var.cluster_name
  main_storage_account_id     = var.storage_account
  workspace_id                = var.workspace_id
}

#####################
# Outputs
#####################

output "container_name" {
   value = azurerm_storage_container.main.name
}
output "storage_account_name" {
    value = azurerm_storage_account.module_strg_acct.name
}

output "workspaceID" {
   value = azurerm_user_assigned_identity.workspaceID.client_id
}

```

## Description of variables

| Name | Description | Required |
| --- | --- | --- |
| location | AKS region where cluster is deployed | yes |
| resource_group_name | Cluster installed resource group name | yes |
| cluster_name | Existing cluster name | yes |
| main_storage_account_id | Existing storage account id | yes |
| workspace_id | Workspace id from IOMETE control plane | yes |
| issuer_url | Data plane issuer url | yes |

