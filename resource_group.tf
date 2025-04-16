resource "azurerm_resource_group" "rg" {
  name     = "jaguar-rg-aks"
  location = var.location
}