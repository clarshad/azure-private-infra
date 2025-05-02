terraform {
  backend "azurerm" {
    resource_group_name  = "jaguar-rg-aks"
    storage_account_name = "jaguarsa"
    container_name       = "jaguarterraformstate"
    key                  = "terraform.tfstate"
  }
}
