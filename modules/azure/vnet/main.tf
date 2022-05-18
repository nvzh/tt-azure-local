#####
# Resource Group
#####
resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-case${var.caseNo}-rg"
  location = var.location
}

##### 
# Network VNET, Subnet
#####
resource "azurerm_virtual_network" "emea-cso-net" {
  name                = "${var.name}-case${var.caseNo}-net"
  address_space       = ["172.16.0.0/12"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "emea-cso-subnet" {
  name                 = "${var.name}-case${var.caseNo}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.emea-cso-net.name
  address_prefixes     = ["172.16.1.0/24"]
}

# ### testing separate subnet for win-vm
# resource "azurerm_subnet" "emea-cso-win-subnet" {
#   name                 = "${var.name}-case${var.caseNo}-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.emea-cso-net.name
#   address_prefixes     = ["172.16.2.0/24"]
# }

resource "azurerm_network_security_group" "emea-cso-sg" {
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