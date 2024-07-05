terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.100.0"
    }
  }
}

provider "azurerm" {
    features {}
  # Configuration options
}



resource "azurerm_resource_group" "this_rg" {
  name     = "ray-rg"
  location = "uk south"
}

resource "azurerm_virtual_network" "this_vnet" {
  name                = "ray-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
}

resource "azurerm_subnet" "this_subnet" {
  name                 = "ray-subnet"
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "this_nic" {
  name                = "ray-nic"
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.this_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "this_win_vm" {
  name                  = "ray-vm"
  location              = azurerm_resource_group.this_rg.location
  resource_group_name   = azurerm_resource_group.this_rg.name
  network_interface_ids = [azurerm_network_interface.this_nic.id]
  vm_size               = "Standard_DS1_v2"


  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "rocinc"
    admin_username = "azure123"
    admin_password = "Haddyhaddy123$"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
 
}