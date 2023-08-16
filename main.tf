data "azurerm_client_config" "current" {}

resource "random_id" "random" {
  byte_length = 3
}

resource "azurerm_resource_group" "main" {
  name     = "${local.cluster_name}-rg"
  location = var.location
  tags     = local.tags
}

  

locals {
  cluster_id           = random_id.random.hex
  cluster_name         = "iom-dataplane-${random_id.random.hex}"
  storage_account_name = "iomdataplane${random_id.random.hex}"
  workspace_id         = var.workspace_id
  module_version       = "1.0.0"


  tags = {
    "iomete.com-cluster_name" : local.cluster_name
    "iomete.com-terraform" : true
    "iomete.com-managed" : true
  }
}



provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
  }
}

resource "null_resource" "save_outputs" {
  depends_on = [
    azurerm_kubernetes_cluster_node_pool.standard_d16plds_v5
  ]
  triggers = {
    run_every_time = uuid()
  }
  provisioner "local-exec" {
    command = <<-EOT

      if [ ! -s "IOMETE_DATA" ]; then
      echo "AKS Name: $(terraform output cluster_name)" >> IOMETE_DATA
      echo "AKS Endpoint: $(terraform output cluster_fqdn)" >> IOMETE_DATA
      echo "Client Certificate: $(terraform output client_certificate)" >> IOMETE_DATA
      echo "Client Key: $(terraform output client_key)" >> IOMETE_DATA
      echo "CA certificate: $(terraform output cluster_ca_certificate)" >> IOMETE_DATA
      fi


    EOT
  }
}

module "storage-configuration" {
  source = "./modules/storage-configuration"

  issuer_url              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  resource_group_name     = azurerm_resource_group.main.name
  location                = var.location
  cluster_name            = local.cluster_name
  main_storage_account_id = azurerm_storage_account.main.id
  workspace_id            = var.workspace_id

}




