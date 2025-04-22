resource "azurerm_linux_virtual_machine" "bastion" {
  name                            = var.vm.bastion.name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = var.vm.bastion.size
  admin_username                  = var.vm.bastion.admin_username
  admin_password                  = var.vm.bastion.admin_password
  network_interface_ids           = [azurerm_network_interface.bastion_nic.id]
  disable_password_authentication = false

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

resource "azurerm_network_interface" "bastion_nic" {
  name                = "jaguar-bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm.bastion.private_ip_address
  }
}
