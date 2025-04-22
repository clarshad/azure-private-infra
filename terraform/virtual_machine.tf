resource "azurerm_linux_virtual_machine" "bastion" {
  name                            = "jaguar-bastion-vm"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_B2s"
  admin_username                  = "jaguar"
  admin_password                  = "Jaguar@1234"
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
    private_ip_address            = "10.241.0.4"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm_master" {
  name                            = "jaguar-master"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_HB120-96rs_v3"
  admin_username                  = "dbmaster"
  admin_password                  = "Jaguar@1234"
  network_interface_ids           = [azurerm_network_interface.db_vm_master_nic.id]
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

resource "azurerm_network_interface" "db_vm_master_nic" {
  name                = "jaguar-master-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.241.1.2"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm_replica" {
  name                            = "jaguar-replica"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  size                            = "Standard_HB120-48rs_v3"
  admin_username                  = "dbreplica"
  admin_password                  = "Jaguar@1234"
  network_interface_ids           = [azurerm_network_interface.db_vm_replica_nic.id]
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

resource "azurerm_network_interface" "db_vm_replica_nic" {
  name                = "jaguar-replica-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.241.1.3"
  }
}