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
  name     = "Group4"
  location = var.azure_region_1
}

################################
# Azure Vnet and Subnets
################################

#Azure Vnet east
resource "azurerm_virtual_network" "Group4-US-East" {
  name                = "Group4-US-East"
  address_space       = ["10.0.2.0/24"]
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
# Azure NSG
################################

#East NSG
resource "azurerm_network_security_group" "East-NSG" {
  name                = "East-NSG"
  location            = var.azure_region_1
  resource_group_name = azurerm_resource_group.Group4-tf.name
  security_rule {
    name                       = "Allow-rdp"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389"]
    source_address_prefixes    = ["*"]
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefixes    = ["*"]
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
    name                       = "Allow-rdp"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["3389"]
    source_address_prefixes    = ["*"]
    destination_address_prefix = "*"
  }
   security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefixes    = ["*"]
    destination_address_prefix = "*"
  }
}

#NSG association to Public Subnet
resource "azurerm_subnet_network_security_group_association" "West-NSG-ASSOC" {
  subnet_id                 = azurerm_subnet.US-West-Public.id
  network_security_group_id = azurerm_network_security_group.West-NSG.id
}