#####
# Resource Group
#####
resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-case${var.caseNo}-rg"
  location = var.location

  tags = {
    Name = "${var.name}-resourceGroup"
    resourceOwner = var.name
    caseNumber    = var.caseNo
  }
}

##### 
# Network VNET, Subnet
#####
resource "azurerm_virtual_network" "cso_net" {
  name                = "${var.name}-case${var.caseNo}-net"
  address_space       = ["172.31.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "cso_subnet" {
  name                 = "${var.name}-case${var.caseNo}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.cso_net.name
  address_prefixes     = ["172.31.0.0/24"]
}

resource "azurerm_network_security_group" "cso_sg" {
  name                = "${var.name}-case${var.caseNo}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allowAll"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}