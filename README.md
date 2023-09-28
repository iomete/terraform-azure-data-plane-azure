# IOMETE Data-Plane module

## Terraform module which creates resources on Azure.
 

## Module Usage

After running terraform apply to create or update your resources, Terraform will automatically generate the IOMETE_DATA file with the necessary information.
Locate the IOMETE_DATA file in your Terraform project directory.

Open the IOMETE_DATA file using a text editor, and Paste the copied information from the IOMETE_DATA file into the respective fields in the IOMETE control plane.


```shell
AKS Name 
AKS Endpoint 
Client Certificate
Client Key
CA certificate

```
Open this file ordinary text editor and copy the content of the file to the IOMETE control plane.

## Terraform code

```hcl

 
 
module "data-plane" {
  source      = "iomete/data-plane-azure/azure"
  version     = "1.0.1"
  account_id  = "account_id"
  location    = "eastus" # Cluster installed region

}


###############################################
# Output
###############################################

output "cluster_name" {
  value       = module.data-plane.aks_name
  description = "The name of the AKS cluster."
}

output "cluster_fqdn" {
  value       = module.data-plane.cluster_fqdn
  description = "The IP address of the AKS cluster's Kubernetes API server endpoint."

}

output "client_certificate" {
  value       = module.data-plane.client_certificate
  description = "The client certificate for authenticating to the AKS cluster."
  sensitive   = true

}

output "client_key" {
  value       = module.data-plane.client_key
  description = "The client key for authenticating to the AKS cluster."
  sensitive   = true

}

output "cluster_ca_certificate" {
  value       = module.data-plane.cluster_ca_certificate
  description = "The cluster CA certificate for the AKS cluster."
  sensitive   = true

}

  
```

## Terraform Deployment

```shell
terraform init
terraform plan
terraform apply
```

## Description of variables

| Name | Description | Required |
| --- | --- | --- |
| location | The location of the AKS cluster. | yes |





# The current principal should have "Storage Blob Data Owner" role on the subscription in order to create the Gen2 storage account
https://stackoverflow.com/questions/75110124/creating-data-lake-causes-error-code-403-or-409-checking-for-existence-of-exist
```hcl
# The current principal should have "Storage Blob Data Owner" role on the subscription in order to create the Gen2 storage account
resource "azurerm_role_assignment" "example" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "storage blob data owner"
  principal_id         = data.azurerm_client_config.current.object_id
}
```