provider "azurerm" {
  features {} 
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-SecurityGroup"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                      = "${var.prefix}-DenyAllTraffic-ntk-sec-rule"
    priority                  = 1000
    direction                 = "Inbound"
    access                    = "Deny"
    protocol                  = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    description = "Deny All traffic"
    destination_address_prefix = "*"
  }

}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = 3                                         # Number of VMs to be created       
  name                            = "${var.prefix}-VM-00-${count.index}"      # Tracks  count for different vm creation
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "${var.username}"
  admin_password                  = "${var.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.*.id[count.index],                         # creates three different ids for different VMs
  ]
  

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-availability-set"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

}


resource  "azurerm_public_ip" "public_ip" {
  name                 = "${var.prefix}_public_ip"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  allocation_method    = "Dynamic"
}


resource "azurerm_lb" "main" {
  name                = "${var.prefix}_Load_Balancer"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}


resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}