# This file contains the configuration for creating an Azure Kubernetes Service (AKS) cluster with a private endpoint and an Application Gateway ingress controller.
# The AKS cluster is configured to use a virtual network and subnet for private communication, and the Application Gateway is set up to handle incoming traffic.

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

  private_cluster_enabled           = true
  role_based_access_control_enabled = true
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }

  identity {
    type = "SystemAssigned"
  }

  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }
}

resource "azurerm_role_assignment" "app_gw_role_assignment" {
  scope                = azurerm_application_gateway.appgw.id
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = "Contributor"
}
