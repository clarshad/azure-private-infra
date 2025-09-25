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
    storage_subnet = {
      name           = "jaguar-storage-subnet"
      address_prefix = ["10.244.0.0/24"]
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
    master_db_server = {
      name               = "jaguar-master-db-server"
      size               = "Standard_D96as_v5"
      admin_username     = "jaguar"
      admin_password     = "Jaguar@1234"
      private_ip_address = "10.243.0.4"
    }
    replica_db_server = {
      name               = "jaguar-replica-db-server"
      size               = "Standard_D48as_v5"
      admin_username     = "jaguar"
      admin_password     = "Jaguar@1234"
      private_ip_address = "10.243.0.5"
    }
    uat_db_server = {
      name               = "jaguar-uat-db-server"
      size               = "Standard_D8as_v5"
      admin_username     = "jaguar"
      admin_password     = "Jaguar@1234"
      private_ip_address = "10.243.0.6"
    }
    uat_app = {
      name               = "jaguar-uat-app-server"
      size               = "Standard_D2as_v5"
      admin_username     = "jaguar"
      admin_password     = "Jaguar@1234"
      private_ip_address = "10.243.0.7"
    }
  }
}