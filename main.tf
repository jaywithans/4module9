################################
# Provider Blocks
################################

#azure default provider block
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

#azure alias provider block
provider "azurerm" {
  alias  = "azure_region_2"
  features {}
  subscription_id = var.azure_subscription_id
}

#aws default provider block
provider "aws" {
  region = var.aws_region_1
}

#aws aliasprovider block
provider "aws" {
  alias = "aws_region_2"
  region = var.aws_region_2
}

################################
# Azure Resource Groups
################################

#azure resource group
resource "azurerm_resource_group" "Group4-tf" {
  name     = "Group4-tf"
  location = var.azure_region_1
}

################################
# Azure Vnet and Subnets
################################

#Azure Vnet east
resource "azurerm_virtual_network" "Group4-US-East" {
  name                = "Group4-US-East"
  address_space       = ["10.0.2.0/24", "10.0.6.0/24"]
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
}

#Azure Subnet east
resource "azurerm_subnet" "US-East-Public" {
  name                 = "US-East-Public"
  resource_group_name  = azurerm_resource_group.Group4-tf.name
  virtual_network_name = azurerm_virtual_network.Group4-US-East.name
  address_prefixes     = ["10.0.2.0/24"]
}

#azure Vnet west
resource "azurerm_virtual_network" "Group4-US-West" {
  name                = "Group4-US-West"
  address_space       = ["10.0.3.0/24"]
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name
}

#Azure Subnet west
resource "azurerm_subnet" "US-West-Public" {
  name                 = "US-West-Public"
  resource_group_name  = azurerm_resource_group.Group4-tf.name
  virtual_network_name = azurerm_virtual_network.Group4-US-West.name
  address_prefixes     = ["10.0.3.0/24"]
}

################################
#Azure network peering
################################

#East-West VNet Peering
resource "azurerm_virtual_network_peering" "East-West-Peering" {
  name                      = "East-West-Peering"
  resource_group_name       = azurerm_resource_group.Group4-tf.name
  virtual_network_name      = azurerm_virtual_network.Group4-US-East.name
  remote_virtual_network_id = azurerm_virtual_network.Group4-US-West.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

#West-East VNet Peering
resource "azurerm_virtual_network_peering" "West-East-Peering" {
  name                      = "West-East-Peering"
  resource_group_name       = azurerm_resource_group.Group4-tf.name
  virtual_network_name      = azurerm_virtual_network.Group4-US-West.name
  remote_virtual_network_id = azurerm_virtual_network.Group4-US-East.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

################################
# Azure NSG
################################

#East NSG
resource "azurerm_network_security_group" "East-NSG" {
  name                = "East-NSG"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  security_rule {
    name                       = "Allow-rdp-Kevin"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389"]
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-SSH-Kevin"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

#NSG association to Public Subnet
resource "azurerm_subnet_network_security_group_association" "East-NSG-ASSOC" {
  subnet_id                 = azurerm_subnet.US-East-Public.id
  network_security_group_id = azurerm_network_security_group.East-NSG.id
}

#West NSG
resource "azurerm_network_security_group" "West-NSG" {
  name                = "West-NSG"
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name
  security_rule {
    name                       = "Allow-rdp-Kevin"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389"]
    source_address_prefix    = var.my_ip
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Allow-SSH-Kevin"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix    = var.my_ip
    destination_address_prefix = "*"
  }
}

#NSG association to Public Subnet
resource "azurerm_subnet_network_security_group_association" "West-NSG-ASSOC" {
  subnet_id                 = azurerm_subnet.US-West-Public.id
  network_security_group_id = azurerm_network_security_group.West-NSG.id
}

################################
# Azure Network Interfaces
################################

# Network interface for East Windows NIC
resource "azurerm_network_interface" "East-Windows-NIC" {
  name                = "East-Windows-NIC"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.US-East-Public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network interface for East Linux NIC
resource "azurerm_network_interface" "East-Linux-NIC" {
  name                = "East-Linux-NIC"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.US-East-Public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network interface for West Windows NIC
resource "azurerm_network_interface" "West-Windows-NIC" {
  name                = "West-Windows-NIC"
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.US-West-Public.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network interface for West Linux NIC
resource "azurerm_network_interface" "West-Linux-NIC" {
  name                = "West-Linux-NIC"
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.US-West-Public.id
    private_ip_address_allocation = "Dynamic"
  }
}

################################
# Azure Public IPs
################################

# PIP for Windows VM in East region
resource "azurerm_public_ip" "East-Windows-PIP" {
  name                = "East-Windows-PIP"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  allocation_method   = "Static"
}

# PIP for Linux VM in East region
resource "azurerm_public_ip" "East-Linux-PIP" {
  name                = "East-Linux-PIP"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  allocation_method   = "Static"
}

# PIP for Windows VM in West region
resource "azurerm_public_ip" "West-Windows-PIP" {
  name                = "West-Windows-PIP"
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name
  allocation_method   = "Static"
}

# PIP for Linux VM in West region
resource "azurerm_public_ip" "West-Linux-PIP" {
  name                = "West-Linux-PIP"
  location            = var.azure_region_2
  resource_group_name = azurerm_resource_group.Group4-tf.name
  allocation_method   = "Static"
}

################################
# Azure Virtual Machines
################################

# Windows VM in East region
resource "azurerm_windows_virtual_machine" "East-Windows-VM" {
  name                = "East-Windows-VM"
  resource_group_name = azurerm_resource_group.Group4-tf.name
  location            = var.azure_region_1
  size                = "Standard_B1s"
  admin_username      = var.azure_windows_username
  admin_password      = var.azure_windows_password
  network_interface_ids = [
    azurerm_network_interface.East-Windows-NIC.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}

# Linux VM in East region
resource "azurerm_linux_virtual_machine" "East-Linux-VM" {
  name                = "East-Linux-VM"
  resource_group_name = azurerm_resource_group.Group4-tf.name
  location            = var.azure_region_1
  size                = "Standard_B1s"
  admin_username      = var.azure_linux_username
  network_interface_ids = [
    azurerm_network_interface.East-Linux-NIC.id,
  ]
  admin_ssh_key {
    username   = var.azure_linux_username
    public_key = file(var.public_key_path)
  }
  disable_password_authentication = true
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# Windows VM in West region
resource "azurerm_windows_virtual_machine" "West-Windows-VM" {
  name                = "West-Windows-VM"
  resource_group_name = azurerm_resource_group.Group4-tf.name
  location            = var.azure_region_2
  size                = "Standard_B1s"
  admin_username      = var.azure_windows_username
  admin_password      = var.azure_windows_password
  network_interface_ids = [
    azurerm_network_interface.West-Windows-NIC.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}

# Linux VM in West region
resource "azurerm_linux_virtual_machine" "West-Linux-VM" {
  name                = "West-Linux-VM"
  resource_group_name = azurerm_resource_group.Group4-tf.name
  location            = var.azure_region_2
  size                = "Standard_B1s"
  admin_username      = var.azure_linux_username
  network_interface_ids = [
    azurerm_network_interface.West-Linux-NIC.id,
  ]
  admin_ssh_key {
    username   = var.azure_linux_username
    public_key = file(var.public_key_path)
  }
  disable_password_authentication = true
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

################################
# Azure VPN gateway
################################

# Subnet for VPN gateway
resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.Group4-tf.name
  virtual_network_name = azurerm_virtual_network.Group4-US-East.name
  address_prefixes     = ["10.0.6.0/24"]
}

# Public IP for VPN
resource "azurerm_public_ip" "VNG-PublicIP" {
  name                = "VNG-PublicIP"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  allocation_method   = "Static"
}

# VPN gateway
resource "azurerm_virtual_network_gateway" "VNG-Group4" {
  name                = "VNG-Group4"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1"

  ip_configuration {
    name                          = "VNG-IPConfig"
    subnet_id                     = azurerm_subnet.GatewaySubnet.id
    public_ip_address_id          = azurerm_public_ip.VNG-PublicIP.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Local network gateway
resource "azurerm_local_network_gateway" "LNG-Group4" {
  name                = "LNG-Group4"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  gateway_address     = azurerm_public_ip.VNG-PublicIP.ip_address
  address_space       = ["10.0.1.0/24"]
}

# VPN connection from Azure to AWS (not finished due to missing AWS resources)
#resource "azurerm_virtual_network_gateway_connection" "VNG-Connection-Group4" {
#  name                = "VNG-Connection-Group4"
#  location            = var.azure_region_1
#  resource_group_name = azurerm_resource_group.Group4-tf.name
#  type                = "IPsec"
#  virtual_network_gateway_id = azurerm_virtual_network_gateway.VNG-Group4.id
#  local_network_gateway_id    = azurerm_local_network_gateway.LNG-Group4.id
#
#  shared_key = 
#}