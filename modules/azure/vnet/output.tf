output "rg" {
  value = azurerm_resource_group.rg.name
}

# output "id" {
#   value = azurerm_virtual_network.vnet.id
# }

# output "subnet_name" {
#   value = azurerm_subnet.emea-cso-subnet.name
# }

output "subnet_id" {
  value = azurerm_subnet.emea-cso-subnet.id
}

# ### testing separate subnet for win-vm
# output "subnet_win_id" {
#   value = azurerm_subnet.emea-cso-win-subnet.id
# }

output "security_group_id" {
  value = azurerm_network_security_group.emea-cso-sg.id
}