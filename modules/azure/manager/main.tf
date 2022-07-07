resource "azurerm_public_ip" "cso_manager_pub_ip" {
  name                = "${var.name}-case${var.caseNo}-manager-public-ip-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  domain_name_label   = "${var.name}-case${var.caseNo}-manager-${count.index}"

  tags = {
    Name          = format("%s-manager-pubip-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "publicIP"
  }
}

resource "azurerm_network_interface" "cso_manager_interface" {
  name                = "${var.name}-case${var.caseNo}-net-manager-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "cso-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.cso_manager_pub_ip.*.id, count.index)
  }

  tags = {
    Name          = format("%s-manager-int-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "networkInterface"
  }
}

### MANAGER INSTANCE ###

resource "azurerm_virtual_machine" "cso_manager_vm" {
  depends_on = [azurerm_network_interface_security_group_association.cso_allow_ssh]

  name                  = "${var.name}-case${var.caseNo}-manager-${count.index}"
  count                 = var.manager_count
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [element(azurerm_network_interface.cso_manager_interface.*.id, count.index)]
  vm_size               = var.manager_instance_type

  ### Uncomment that line if you're going to use LB
  #availability_set_id = azurerm_availability_set.emea_cso_manager_avset.id

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
    name              = "cso-manager-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "cso-manager-${count.index}"
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

  tags = {
    Name          = format("%s-manager-vm-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "instance"
    role          = "manager"
  }
}

resource "azurerm_network_interface_security_group_association" "cso_allow_ssh" {
  count                     = length(azurerm_network_interface.cso_manager_interface)
  network_interface_id      = azurerm_network_interface.cso_manager_interface[count.index].id
  network_security_group_id = var.security_group_id
}
