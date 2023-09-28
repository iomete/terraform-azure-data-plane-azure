data "azurerm_subscription" "current" {}

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

resource "kubernetes_secret" "data-plane-secret" {

  metadata {
    name = "iomete-data-plane-secret"
  }

  data = {
    "settings" = jsonencode({
      cloud        = "azure",
      region       = var.location,
      cluster_name = var.cluster_name,

      storage_configuration = {
        lakehouse_storage_account_name = var.lakehouse_storage_account_name,
        lakehouse_container_name       = azurerm_storage_container.lakehouse.name,
        assets_container_name          = azurerm_storage_container.assets.name,
        lakehouse_storage_account_key = azurerm_storage_account.lakehouse_storage_account.primary_access_key
      },

      workload_identity = {
        tenant_id                             = data.azurerm_client_config.current.tenant_id,
        lakehouse_user_assigned_identity_name = local.lakehouse_user_assigned_identity_name
        client_id                             = data.azurerm_client_config.current.client_id,
        resource_group_name                   = azurerm_resource_group.main.name,
        node_resource_group_name              = azurerm_kubernetes_cluster.main.node_resource_group
      },
      aks = {
        name            = azurerm_kubernetes_cluster.main.name,
        endpoint        = azurerm_kubernetes_cluster.main.kube_config.0.host,
        cluster_fqdn    = azurerm_kubernetes_cluster.main.fqdn,
        oidc_issuer_url = azurerm_kubernetes_cluster.main.oidc_issuer_url
      },
      terraform = {
        module_version = local.module_version
      }
    })
  }

  type = "opaque"

  depends_on = [
    azurerm_kubernetes_cluster.main
  ]
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name = "fluxcd"
  }
}


resource "helm_release" "fluxcd" {
  name       = "helm-operator"
  namespace  = "fluxcd"
  repository = "https://fluxcd-community.github.io/helm-charts"
  version    = "2.9.2"
  chart      = "flux2"
  depends_on = [
    kubernetes_namespace.fluxcd
  ]
  set {
    name  = "imageReflectionController.create"
    value = "false"
  }

  set {
    name  = "imageAutomationController.create"
    value = "false"
  }

  set {
    name  = "kustomizeController.create"
    value = "false"
  }

  set {
    name  = "notificationController.create"
    value = "false"
  }
}