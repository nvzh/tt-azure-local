resource "azurerm_public_ip" "cso_msr_pub_ip" {
  name                = "${var.name}-case${var.caseNo}-msr-instance-public-ip-${count.index}"
  count               = var.msr_count
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"

  tags = {
    Name          = format("%s-msr-pubip-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "publicIP"
  }
}

resource "azurerm_network_interface" "cso_msr_interface" {
  name                = "${var.name}-case${var.caseNo}-msr-net-interface-${count.index}"
  count               = var.msr_count
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "cso-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.cso_msr_pub_ip.*.id, count.index)
  }

  tags = {
    Name          = format("%s-msr-int-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "networkInterface"
  }
}

resource "azurerm_network_interface_security_group_association" "cso_msr_allow_ssh" {
  count                     = length(azurerm_network_interface.cso_msr_interface)
  network_interface_id      = azurerm_network_interface.cso_msr_interface[count.index].id
  network_security_group_id = var.security_group_id
}

### MSR INSTANCE ###

resource "azurerm_virtual_machine" "cso_msr_vm" {
  depends_on = [azurerm_network_interface_security_group_association.cso_msr_allow_ssh]

  name                  = "${var.name}-case${var.caseNo}-msr-${count.index}"
  count                 = var.msr_count
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [element(azurerm_network_interface.cso_msr_interface.*.id, count.index)]
  vm_size               = var.msr_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${ var.os_name == "UbuntuServer" ? "Canonical" : 
                    (var.os_name == "RHEL" ? "redhat" : 
                    (var.os_name == "0001-com-ubuntu-server-focal" ? "Canonical" : 
                    (var.os_name == "CentOS" ? "OpenLogic" : "here-should-be-suse" )))}"
    offer     = var.os_name
    sku       = var.os_version
    version   = "latest"
  }
  storage_os_disk {
    name              = "cso-msr-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "cso-msr-${count.index}"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#!/bin/bash
sudo systemctl stop firewalld && sudo systemctl disable firewalld
yum install -y nfs-utils || apt install -y nfs-common || zypper -n in nfs-client -y
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
    Name          = format("%s-msr-vm-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "instance"
    role          = "msr"
  }
}