resource "azurerm_container_registry" "cr" {
  name                = "jaguaracr"
  admin_enabled       = true
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}