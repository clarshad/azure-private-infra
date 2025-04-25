# This file contains the configuration for creating an Azure Kubernetes Service (AKS) cluster with a private endpoint and an Application Gateway ingress controller.
# The AKS cluster is configured to use a virtual network and subnet for private communication, and the Application Gateway is set up to handle incoming traffic.

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "jaguar-private-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "privateaks"

  default_node_pool {
    name                 = "nodepool1"
    vm_size              = "Standard_D8ds_v5"
    vnet_subnet_id       = azurerm_subnet.aks_subnet.id
    auto_scaling_enabled = true
    min_count            = 2
    max_count            = 50
    upgrade_settings {
      drain_timeout_in_minutes      = 30
      max_surge                     = "50%"
      node_soak_duration_in_minutes = 10
    }
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

resource "azurerm_role_assignment" "app_gw_contributor_role_assignment" {
  scope                = azurerm_application_gateway.appgw.id
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "vnet_network_contributor_role_assignment" {
  scope                = azurerm_subnet.appgw_subnet.id
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks_acr_pull_role_assignment" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.cr.id
  skip_service_principal_aad_check = true
}