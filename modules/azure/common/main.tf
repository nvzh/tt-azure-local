# Creating two random password for MKE username and Password
resource "random_pet" "mke_username" {
  length  = 2
}

resource "random_string" "mke_password" {
  length  = 20
  special = false
}

#####
# Cluster wide NSG
#####
# resource "azurerm_network_security_group" "emea-cso-sg" {
#   name                = "${var.name}-case${var.caseNo}-sg"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.emea-cso-rg.name

#   security_rule {
#     name                       = "allowAll"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "*"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_network_interface_security_group_association" "emea-cso-allow-ssh" {
#   count                     = length(azurerm_network_interface.emea-cso-interface)
#   network_interface_id      = azurerm_network_interface.emea-cso-interface[count.index].id
#   network_security_group_id = azurerm_network_security_group.emea-cso-sg.id
# }

#####
# Rules for master NSG
#####
resource "azurerm_storage_account" "emea-cso-sa" {
  name                      = "case${var.caseNo}sa"
  resource_group_name       = var.rg
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}