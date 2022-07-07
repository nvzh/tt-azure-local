resource "azurerm_public_ip" "cso_nfs_pub_ip" {
  name                = "${var.name}-case${var.caseNo}-nfs-instance-public-ip"
  count               = var.nfs_backend
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  domain_name_label   = "${var.name}-case${var.caseNo}-nfs"

  tags = {
    Name          = format("%s-nfs-pubip-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "publicIP"
  }
}

resource "azurerm_network_interface" "cso_nfs_interface" {
  name                = "${var.name}-case${var.caseNo}-nfs-net-interface"
  count               = var.nfs_backend
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "cso-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.cso_nfs_pub_ip.*.id, count.index)
  }

  tags = {
    Name          = format("%s-nfs-int-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "networkInterface"
  }
}

resource "azurerm_network_interface_security_group_association" "cso_nfs_allow_ssh" {
  count                     = length(azurerm_network_interface.cso_nfs_interface)
  network_interface_id      = azurerm_network_interface.cso_nfs_interface[count.index].id
  network_security_group_id = var.security_group_id
}

### NFS INSTANCE ###

resource "azurerm_virtual_machine" "cso_nfs_vm" {
  depends_on = [azurerm_network_interface_security_group_association.cso_nfs_allow_ssh]

  name                  = "${var.name}-case${var.caseNo}-nfs"
  count                 = var.nfs_backend
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [element(azurerm_network_interface.cso_nfs_interface.*.id, count.index)]
  vm_size               = "Standard_D2s_v3"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "cso-nfs-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 100
  }
  os_profile {
    computer_name  = "cso-nfs"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#!/bin/bash
apt update -y
apt install -y nfs-kernel-server nfs-common
mkdir /var/nfs/general -p
chown nobody:nogroup /var/nfs/general
chown -R nobody /var/nfs/general
chmod -R 755 /var/nfs/general
echo '/var/nfs/general    *(rw,sync,no_root_squash,no_subtree_check)' > /etc/exports
systemctl restart nfs-kernel-server
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
    Name          = format("%s-nfs-vm-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "instance"
    role          = "nfs"
  }
}
