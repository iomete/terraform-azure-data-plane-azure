data "azurerm_subscription" "current" {}

resource "kubernetes_secret" "iom-manage-secrets" {

  metadata {
    name = "iomete-manage-secrets"
  }

  data = {
    "settings" = jsonencode({
      region = var.location,
      cloud  = "azure",
      cluster = {
        id                                = local.cluster_id,
        name                              = local.cluster_name,
        resource_group_name               = azurerm_resource_group.main.name,
        node_resource_group_name          = azurerm_kubernetes_cluster.main.node_resource_group,
        azurerm_subscription_tenant_id    = data.azurerm_subscription.current.tenant_id,
        azurerm_subscription_display_name = data.azurerm_subscription.current.display_name
      },

      default_storage_configuration = {
        lakehouse_storage_account_name = module.storage-configuration.storage_account_name,
        lakehouse_storage_account_key  = module.storage-configuration.storage_account_key,
        assets_storage_account_name    = azurerm_storage_account.main.name,
        assets_storage_account_key     = azurerm_storage_account.main.primary_access_key,
        lakehouse_container            = module.storage-configuration.container_name,
        assets_container               = azurerm_storage_container.assets.name,

      },

      workload = {
        tenant_id            = data.azurerm_client_config.current.tenant_id,
        oidc_issuer_url      = azurerm_kubernetes_cluster.main.oidc_issuer_url,
        assets_managed_id    = azurerm_user_assigned_identity.assetsID.client_id,
        workspace_managed_id = module.storage-configuration.workspaceID,
        client_id            = data.azurerm_client_config.current.client_id
      },

      aks = {
        name         = azurerm_kubernetes_cluster.main.name,
        endpoint     = azurerm_kubernetes_cluster.main.kube_config.0.host,
        cluster_fqdn = azurerm_kubernetes_cluster.main.fqdn,
      },

      terraform = {
        module_version = local.module_version
      },

      connection = {
        client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate),
        client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key),
        cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate),
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


resource "helm_release" "iomete-agent" {
  name       = "iomete-agent"
  namespace  = "default"
  repository = "https://chartmuseum.iomete.com"
  chart      = "iom-agent"
  version    = "0.2.0"
  depends_on = [
    helm_release.fluxcd,
    kubernetes_secret.iom-manage-secrets,
  ]

  set {
    name  = "iometeAccountId"
    value = var.account_id
  }

  set {
    name  = "cloud"
    value = "azure"
  }

  set {
    name  = "region"
    value = var.location
  }

}
