output "rg" {
  value = azurerm_resource_group.rg.name
}

output "subnet_id" {
  value = azurerm_subnet.cso_subnet.id
}

output "security_group_id" {
  value = azurerm_network_security_group.cso_sg.id
}