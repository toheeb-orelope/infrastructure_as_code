terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "fac7c7e0-b3f6-4b53-b639-a5c7d56e9952"

}


# Create a resource group
resource "azurerm_resource_group" "CloudScale-RG" {
  name     = "CloudScale-RG"
  location = "eastus"
  tags = {
    environment = "Dev"
  }
}

resource "azurerm_virtual_network" "CloudScale-VN" {
  name                = "CloudScale-VN"
  location            = azurerm_resource_group.CloudScale-RG.location
  resource_group_name = azurerm_resource_group.CloudScale-RG.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_subnet" "CloudScale-Subnet" {
  name                 = "CloudScale-Subnet1"
  resource_group_name  = azurerm_resource_group.CloudScale-RG.name
  virtual_network_name = azurerm_virtual_network.CloudScale-VN.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_security_group" "CloudScale-NSG" {
  name                = "CloudScale_network_security_group"
  location            = azurerm_resource_group.CloudScale-RG.location
  resource_group_name = azurerm_resource_group.CloudScale-RG.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "CloudScale-NSG-Rule" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.CloudScale-RG.name
  network_security_group_name = azurerm_network_security_group.CloudScale-NSG.name
}

resource "azurerm_subnet_network_security_group_association" "CloudScale-Subnet-NSG-Association" {
  subnet_id                 = azurerm_subnet.CloudScale-Subnet.id
  network_security_group_id = azurerm_network_security_group.CloudScale-NSG.id
}

resource "azurerm_public_ip" "CloudScale-pub-ip" {
  name                = "CloudScale-pub-ip"
  resource_group_name = azurerm_resource_group.CloudScale-RG.name
  location            = azurerm_resource_group.CloudScale-RG.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "CloudScale-NetInterface" {
  name                = "CloudScale-NetInterface"
  location            = azurerm_resource_group.CloudScale-RG.location
  resource_group_name = azurerm_resource_group.CloudScale-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.CloudScale-Subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.CloudScale-pub-ip.id
  }

  tags = {
    environment = "Dev"
  }
}


# Create a virtual machine
resource "azurerm_linux_virtual_machine" "CloudScale-VM" {
  name                = "CloudScale-VM"
  resource_group_name = azurerm_resource_group.CloudScale-RG.name
  location            = azurerm_resource_group.CloudScale-RG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.CloudScale-NetInterface.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/azurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${path.module}/${var.vm_os}-ssh-script.tpl", {
      hostname      = self.public_ip_address
      user          = "adminuser"
      identity_file = "~/.ssh/azurekey"
    })

    # interpreter = ["PowerShell", "-Command"]
    # Dynamic interpreter selection based on the operating system of the virtual machine
    interpreter = var.vm_os == "windows" ? ["PowerShell", "-Command"] : ["/bin/bash", "-c"]
  }

  tags = {
    environment = "Dev"
  }
}

# Data source to retrieve the public IP address of the virtual machine
data "azurerm_public_ip" "CloudScale-pub-ip-data" {
  name                = azurerm_public_ip.CloudScale-pub-ip.name
  resource_group_name = azurerm_resource_group.CloudScale-RG.name
}


# Retrieve data dynamically
output "vm_public_ip" {
  value = "${azurerm_linux_virtual_machine.CloudScale-VM.name}: ${data.azurerm_public_ip.CloudScale-pub-ip-data.ip_address}"
}