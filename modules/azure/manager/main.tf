resource "azurerm_public_ip" "emea-cso-manager-pub-ip" {
  name                = "${var.name}-case${var.caseNo}-instance-public-ip-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "emea-cso-manager-interface" {
  name                = "${var.name}-case${var.caseNo}-net-interface-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "emea-cso-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.emea-cso-manager-pub-ip.*.id, count.index)
  }
}

### MANAGER INSTANCE ###

resource "azurerm_virtual_machine" "emea-cso-manager-vm" {
  depends_on = [azurerm_network_interface_security_group_association.emea-cso-allow-ssh]

  name                  = "${var.name}-case${var.caseNo}-managervm-${count.index}"
  count                 = var.manager_count
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [element(azurerm_network_interface.emea-cso-manager-interface.*.id, count.index)]
  vm_size               = var.manager_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${ var.os_name == "UbuntuServer" ? "Canonical" : 
                    (var.os_name == "RHEL" ? "redhat" : 
                    (var.os_name == "0001-com-ubuntu-server-focal" ? "Canonical" : 
                    (var.os_name == "CentOS" ? "OpenLogic" : "here-should-be-suse" )))}"
    #publisher = "Canonical"
    offer     = var.os_name
    sku       = var.os_version
    version   = "latest"
  }
  storage_os_disk {
    name              = "emea-cso-manager-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "emea-cso-managervm-${count.index}"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#cloud-config
bootcmd:
 - >
   sudo systemctl stop firewalld && sudo systemctl disable firewalld
EOF
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("/Users/nvzh/.ssh/id_rsa.pub")
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "emea-cso-allow-ssh" {
  count                     = length(azurerm_network_interface.emea-cso-manager-interface)
  network_interface_id      = azurerm_network_interface.emea-cso-manager-interface[count.index].id
  network_security_group_id = var.security_group_id
}
