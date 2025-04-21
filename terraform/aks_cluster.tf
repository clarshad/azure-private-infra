resource "azurerm_kubernetes_cluster" "aks" {
  name                = "jaguar-private-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "privateaks"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  private_cluster_enabled           = true
  role_based_access_control_enabled = true
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  ingress_application_gateway {
    gateway_id                 = azurerm_application_gateway.appgw.id
  }
}

