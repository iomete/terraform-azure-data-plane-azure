
##############################################
#Activate Workload Identity
##############################################

resource "null_resource" "register_workload_identity" {
  provisioner "local-exec" {
    command    = "az feature register --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview "
    on_failure = fail
  }
}

resource "null_resource" "create_workload_identity_status" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    null_resource.register_workload_identity
  ]
  provisioner "local-exec" {
    command    = "az feature show --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview | jq -r .properties.state > status.txt"
    on_failure = fail
  }
}

resource "null_resource" "check_workload_identity_status" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [
    null_resource.create_workload_identity_status
  ]
  provisioner "local-exec" {
    command    = "if [ $(cat status.txt) = 'Registered' ]; then $(exit 0); else echo 'EnableWorkloadIdentityPreview not enabled'; $(exit 1); fi"
    on_failure = fail
  }
}

###############################################
# AKS Cluster
###############################################

resource "azurerm_kubernetes_cluster" "main" {
  name = var.cluster_name
  ### choose the resource goup to use for the cluster
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  node_resource_group       = "${var.cluster_name}-noderg"
  dns_prefix                = var.cluster_name
  kubernetes_version        = var.orchestrator_version
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  default_node_pool {
    name                        = "systempool"
    zones                       = [1]
    node_count                  = 1
    min_count                   = 1
    max_count                   = 3
    max_pods                    = 110
    vm_size                     = var.system_vm_size
    vnet_subnet_id              = azurerm_subnet.nv-sn-cluster.id
    type                        = "VirtualMachineScaleSets"
    enable_auto_scaling         = true
    enable_host_encryption      = false
    temporary_name_for_rotation = "nodeupgrade"
    node_labels = {
      "k8s.iomete.com/node-purpose" = "microservices-single-zone"
    }
  }

  tags = local.tags
  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
    network_policy    = "azure"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  http_application_routing_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

###############################################
# driver pool
###############################################

resource "azurerm_kubernetes_cluster_node_pool" "standard_e2pds_v5" {
  name                  = "stde2pdsv5dr"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_E2ps_v5"
  node_count            = 0
  enable_auto_scaling   = true
  min_count             = null
  max_count             = var.driver_max_count
  priority              = "Regular"
  os_type               = "Linux"
  orchestrator_version  = var.orchestrator_version
  vnet_subnet_id        = azurerm_subnet.nv-sn-cluster.id

  #os_disk_size_gb = 30
  tags = local.tags
  node_labels = {
    "k8s.iomete.com/node-purpose" = "stde2pdsv5dr"
  }

  node_taints = ["k8s.iomete.com/dedicated=stde2pdsv5dr:NoSchedule"]

  depends_on = [azurerm_kubernetes_cluster.main]
}

resource "azurerm_kubernetes_cluster_node_pool" "standard_e4ps_v5" {
  name                  = "stde4psv5"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_E4ps_v5"
  node_count            = 0
  enable_auto_scaling   = true
  min_count             = null
  max_count             = var.driver_max_count
  priority              = "Regular"
  os_type               = "Linux"
  orchestrator_version  = var.orchestrator_version
  vnet_subnet_id        = azurerm_subnet.nv-sn-cluster.id

  #os_disk_size_gb = 30
  tags = local.tags
  node_labels = {
    "k8s.iomete.com/node-purpose" = "stde4psv5"
  }

  node_taints = ["k8s.iomete.com/dedicated=stde4psv5:NoSchedule"]

  depends_on = [azurerm_kubernetes_cluster.main]
}



##############################################
# executer pool
##############################################

resource "azurerm_kubernetes_cluster_node_pool" "standard_e2pds_v5_exec" {
  name                  = "stde2pdsv5"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_E2pds_v5"
  node_count            = 0
  enable_auto_scaling   = true
  min_count             = null
  max_count             = var.exec_max_count
  priority              = "Regular"
  os_type               = "Linux"
  orchestrator_version  = var.orchestrator_version
  vnet_subnet_id        = azurerm_subnet.nv-sn-cluster.id

  #os_disk_size_gb = 30
  tags = local.tags
  node_labels = {
    "k8s.iomete.com/node-purpose" = "stde2pdsv5"
  }

  node_taints = ["k8s.iomete.com/dedicated=stde2pdsv5:NoSchedule"]

  depends_on = [azurerm_kubernetes_cluster.main]
}


resource "azurerm_kubernetes_cluster_node_pool" "standard_e4pds_v5" {
  name                  = "stde4pdsv5"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_E4pds_v5"
  node_count            = 0
  enable_auto_scaling   = true
  min_count             = null
  max_count             = var.exec_max_count
  priority              = "Regular"
  os_type               = "Linux"
  orchestrator_version  = var.orchestrator_version
  vnet_subnet_id        = azurerm_subnet.nv-sn-cluster.id

  #os_disk_size_gb = 30
  tags = local.tags
  node_labels = {
    "k8s.iomete.com/node-purpose" = "stde4pdsv5"
  }

  node_taints = ["k8s.iomete.com/dedicated=stde4pdsv5:NoSchedule"]

  depends_on = [azurerm_kubernetes_cluster.main]
}


resource "azurerm_kubernetes_cluster_node_pool" "standard_d16plds_v5" {
  name                  = "std16pldsv5"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D16plds_v5"
  node_count            = 0
  enable_auto_scaling   = true
  min_count             = null
  max_count             = var.exec_max_count
  priority              = "Regular"
  os_type               = "Linux"
  orchestrator_version  = var.orchestrator_version
  vnet_subnet_id        = azurerm_subnet.nv-sn-cluster.id

  tags = local.tags
  node_labels = {
    "k8s.iomete.com/node-purpose" = "std16pldsv5"
  }

  node_taints = ["k8s.iomete.com/dedicated=std16pldsv5:NoSchedule"]

  depends_on = [azurerm_kubernetes_cluster.main]
}