variable "location" {
  default = "Central India"
}

variable "vnet" {
  default = {
    name          = "jaguar-vnet-aks"
    address_space = ["10.0.0.0/8"]
  }
}

variable "subnets" {
  default = {
    aks = {
      name           = "jaguar-aks-subnet"
      address_prefix = ["10.240.0.0/16"]
    }
    bastion = {
      name           = "jaguar-bastion-subnet"
      address_prefix = ["10.241.0.0/24"]
    }
    vm_subnet = {
      name           = "jaguar-db-vm-subnet"
      address_prefix = ["10.243.0.0/24"]
    }
    appgw_subnet = {
      name           = "jaguar-appgw-subnet"
      address_prefix = ["10.242.0.0/24"]
    }
  }
}

variable "vm" {
  default = {
    bastion = {
      name               = "jaguar-bastion-vm"
      size               = "Standard_B2s"
      admin_username     = "jaguar"
      admin_password     = "Jaguar@1234"
      private_ip_address = "10.241.0.4"
    }
  }
}