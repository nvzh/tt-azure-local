### Uncomment everything if you're going to use LB (do not forget uncomment 'availability set' in manager's VM config)

# # Create Public IP for LB
# resource "azurerm_public_ip" "emea-cso-lb-ip" {
#   name                = "${var.name}-case${var.caseNo}-lb-ip"
#   location            = var.location
#   resource_group_name = var.rg
#   allocation_method   = "Static"
#   #sku                 = "Basic"
#   domain_name_label   = "mke-${var.name}-case${var.caseNo}"
# }

# # Create LB
# resource "azurerm_lb" "emea-cso-lb" {
#   #depends_on          = [azurerm_availability_set.emea_cso_manager_avset]
#   name                = "${var.name}-case${var.caseNo}-lb"
#   location            = var.location
#   resource_group_name = var.rg
#   sku                 = "Basic"

#   frontend_ip_configuration {
#     name                 = "mke-LB-FrontendIP"
#     public_ip_address_id = join("", azurerm_public_ip.emea-cso-lb-ip.*.id)
#   }
# }

# # Create backend address pool
# resource "azurerm_lb_backend_address_pool" "emea-cso-mke_lb_be_pool" {
#   name            = "${var.name}-case${var.caseNo}-mke-be-pool"
#   #resource_group_name = var.rg
#   loadbalancer_id = azurerm_lb.emea-cso-lb.id
# }

# resource "azurerm_network_interface_backend_address_pool_association" "emea_cso_mke_lb_be_pool_assoc" {
#   count                   = length(azurerm_network_interface.emea-cso-manager-interface)
#   network_interface_id    = azurerm_network_interface.emea-cso-manager-interface[count.index].id
#   #ip_configuration_name   = "emea-cso-ip-configuration"
#   ip_configuration_name   = format("%s-master-Net-%s", var.name, count.index + 1)
#   backend_address_pool_id = azurerm_lb_backend_address_pool.emea-cso-mke_lb_be_pool.id
# }

# # Create LB rule for MKE port 443
# resource "azurerm_lb_rule" "emea-cso-lb-rule-443" {
#   #resource_group_name            = var.rg
#   loadbalancer_id                = azurerm_lb.emea-cso-lb.id
#   name                           = "${var.name}-case${var.caseNo}-LBRule-for-mke-443"
#   protocol                       = "Tcp"
#   frontend_port                  = 443
#   backend_port                   = 443
#   frontend_ip_configuration_name = "mke-LB-FrontendIP"
#   enable_floating_ip             = false
#   #backend_address_pool_ids        = azurerm_lb_backend_address_pool.emea-cso-mke_lb_be_pool.id
#   idle_timeout_in_minutes        = 5
#   probe_id                       = azurerm_lb_probe.emea-cso-lb-probe-443.id
# }

# # Create LB rule for MKE port 6443
# resource "azurerm_lb_rule" "emea-cso-lb-rule-6443" {
#   #resource_group_name            = var.rg
#   loadbalancer_id                = azurerm_lb.emea-cso-lb.id
#   name                           = "${var.name}-case${var.caseNo}-LBRule-for-mke-6443"
#   protocol                       = "Tcp"
#   frontend_port                  = 6443
#   backend_port                   = 6443
#   frontend_ip_configuration_name = "mke-LB-FrontendIP"
#   enable_floating_ip             = false
#   #backend_address_pool_ids        = azurerm_lb_backend_address_pool.emea-cso-mke_lb_be_pool.id
#   idle_timeout_in_minutes        = 5
#   probe_id                       = azurerm_lb_probe.emea-cso-lb-probe-6443.id
# }

# # Create LB probe port 443 MKE
# resource "azurerm_lb_probe" "emea-cso-lb-probe-443" {
#   #resource_group_name = var.rg
#   loadbalancer_id     = azurerm_lb.emea-cso-lb.id
#   name                = "probe_mke_443"
#   protocol            = "Tcp"
#   port                = 443
#   interval_in_seconds = 5
#   number_of_probes    = 2
# }

# # Create LB probe port 6443 MKE
# resource "azurerm_lb_probe" "emea-cso-lb-probe-6443" {
#   #resource_group_name = var.rg
#   loadbalancer_id     = azurerm_lb.emea-cso-lb.id
#   name                = "probe_mke_6443"
#   protocol            = "Tcp"
#   port                = 6443
#   interval_in_seconds = 5
#   number_of_probes    = 2
# }

# #####
# # AVSet for master
# # NOTE: The number of Fault & Update Domains varies depending on which Azure Region you're using.
# #####
# resource "azurerm_availability_set" "emea_cso_manager_avset" {
#   name                         = "${var.name}-case${var.caseNo}-manager-avset"
#   location                     = var.location
#   resource_group_name          = var.rg
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
# }