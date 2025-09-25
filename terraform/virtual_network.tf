resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = var.vnet.address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnets.aks.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.aks.address_prefix
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.subnets.bastion.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.bastion.address_prefix
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = var.subnets.vm_subnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.vm_subnet.address_prefix
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = var.subnets.appgw_subnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.appgw_subnet.address_prefix
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "storage_subnet" {
  name                 = var.subnets.storage_subnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnets.storage_subnet.address_prefix
  private_endpoint_network_policies = "Enabled"
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_route_table" "aks_route_table" {
  name                = "jaguar-aks-udr"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.aks_route_table.id
}
