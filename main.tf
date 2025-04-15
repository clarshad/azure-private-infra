# main.tf

provider "azurerm" {
  features {}
}

variable "location" {
  default = "eastus"
}

resource "azurerm_resource_group" "rg" {
  name     = "jaguar-rg-aks"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "jaguar-vnet-aks"
  address_space       = ["10.0.0.0/8"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "jaguar-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "jaguar-bastion-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.241.0.0/24"]
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "jaguar-appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.242.0.0/24"]
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "jaguar-bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.241.0.4"
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "jaguar-bastion-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "private-aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "privateaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  private_cluster_enabled = true
  role_based_access_control_enabled = true
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
  }
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgateway"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "backendPool"
  }

  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "httpSettings"
  }
}

resource "azurerm_role_assignment" "agic" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_application_gateway.appgw.id
}

resource "helm_release" "agic" {
  name       = "agic"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "ingress-azure"
  version    = "1.5.0"
  namespace  = "default"
  create_namespace = false

  set {
    name  = "appgw.name"
    value = azurerm_application_gateway.appgw.name
  }

  set {
    name  = "appgw.resourceGroup"
    value = azurerm_resource_group.rg.name
  }

  set {
    name  = "appgw.subscriptionId"
    value = data.azurerm_client_config.current.subscription_id
  }

  set {
    name  = "appgw.shared"
    value = "false"
  }

  set {
    name  = "armAuth.type"
    value = "msi"
  }

  set {
    name  = "armAuth.identityResourceID"
    value = azurerm_kubernetes_cluster.aks.identity[0].identity_resource_id
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_kubernetes_cluster.aks.identity[0].client_id
  }

  set {
    name  = "rbac.enabled"
    value = "true"
  }

  set {
    name  = "verbosityLevel"
    value = "3"
  }
}

data "azurerm_client_config" "current" {}
