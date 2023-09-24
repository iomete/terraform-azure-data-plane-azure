###############################################
# Virtual Network
###############################################
resource "azurerm_virtual_network" "vn" {
  depends_on = [
    azurerm_resource_group.main
  ]
  address_space       = var.address_space
  location            = azurerm_resource_group.main.location
  name                = "${var.cluster_name}-vn"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_subnet" "nv-sn-cluster" {
  address_prefixes     = var.cluster_subnet
  name                 = "${var.cluster_name}-cluster-sn"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vn.name
  depends_on           = [azurerm_resource_group.main]
}