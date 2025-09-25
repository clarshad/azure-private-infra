# Private DNS Zone for Blob Storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# VNet Link to Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "vnetlink" {
  name                  = "vnet-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_storage_account" "storage" {
  name                 = "stgaccountjaguar"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
  https_traffic_only_enabled = true
  is_hns_enabled           = false
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = [
        azurerm_subnet.vm_subnet.id,
        azurerm_subnet.aks_subnet.id,
        azurerm_subnet.bastion_subnet.id,
        azurerm_subnet.appgw_subnet.id,
        azurerm_subnet.storage_subnet.id
        ]
  }
}

# Create Two Blob Containers
locals {
  container_names = ["jaguardocs", "jaguarreports"]
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(local.container_names)
  name                  = each.key
  storage_account_id  = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "pe" {
  name                 = "stgaccountjaguar-pe"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  subnet_id            = azurerm_subnet.storage_subnet.id

  private_service_connection {
    name                           = "stgaccountjaguar-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}