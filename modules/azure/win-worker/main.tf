resource "azurerm_public_ip" "cso_win_pub_ip" {
  name                = "${var.name}-case${var.caseNo}-win-instance-public-ip-${count.index}"
  count               = var.win_worker_count
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  domain_name_label   = "${var.name}-case${var.caseNo}-win-${count.index}"

  tags = {
    Name          = format("%s-win-pubip-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "publicIP"
  }
}

resource "azurerm_network_interface" "cso_win_interface" {
  name                = "${var.name}-case${var.caseNo}-win-net-interface-${count.index}"
  count               = var.win_worker_count
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "cso-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.cso_win_pub_ip.*.id, count.index)
  }

  tags = {
    Name          = format("%s-win-int-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "networkInterface"
  }
}

resource "azurerm_network_interface_security_group_association" "cso_win_allow_ssh" {
  count                     = length(azurerm_network_interface.cso_win_interface)
  network_interface_id      = azurerm_network_interface.cso_win_interface[count.index].id
  network_security_group_id = var.security_group_id
}

### WINDOWS INSTANCE ###

resource "azurerm_virtual_machine" "cso_win_vm" {
    depends_on = [azurerm_network_interface_security_group_association.cso_win_allow_ssh]

    name                  = "${var.name}-case${var.caseNo}-win-${count.index}"
    count                 = var.win_worker_count
    location              = var.location
    resource_group_name   = var.rg
    network_interface_ids = [element(azurerm_network_interface.cso_win_interface.*.id, count.index)]
    vm_size               = "Standard_D4s_v3"

    storage_os_disk {
    name              = "cso-win-osdisk-${count.index}"
    create_option     = "FromImage"
    caching           = "None"
    managed_disk_type = "Premium_LRS"
  }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-datacenter-gensecond"
        version   = "latest"
    }

  os_profile {
    computer_name  = "win-vm-${count.index}"
    admin_username = "azureuser"
    admin_password = var.password
    custom_data    = <<EOF
# Set Administrator password
([adsi]("WinNT://./administrator, user")).SetPassword("${var.password}")

# Snippet to enable WinRM over HTTPS with a self-signed certificate
# from https://gist.github.com/TechIsCool/d65017b8427cfa49d579a6d7b6e03c93
Write-Output "Disabling WinRM over HTTP..."
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"
Get-ChildItem WSMan:\Localhost\listener | Remove-Item -Recurse

Write-Output "Configuring WinRM for HTTPS..."
Set-Item -Path WSMan:\LocalHost\MaxTimeoutms -Value '1800000'
Set-Item -Path WSMan:\LocalHost\Shell\MaxMemoryPerShellMB -Value '1024'
Set-Item -Path WSMan:\LocalHost\Service\AllowUnencrypted -Value 'false'
Set-Item -Path WSMan:\LocalHost\Service\Auth\Basic -Value 'true'
Set-Item -Path WSMan:\LocalHost\Service\Auth\CredSSP -Value 'true'

New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Domain,Private

New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP-PUBLIC" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Public

$Hostname = [System.Net.Dns]::GetHostByName((hostname)).HostName.ToUpper()
$pfx = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $Hostname
$certThumbprint = $pfx.Thumbprint
$certSubjectName = $pfx.SubjectName.Name.TrimStart("CN = ").Trim()

New-Item -Path WSMan:\LocalHost\Listener -Address * -Transport HTTPS -Hostname $certSubjectName -CertificateThumbPrint $certThumbprint -Port "5986" -force

Write-Output "Restarting WinRM Service..."
Stop-Service WinRM
Set-Service WinRM -StartupType "Automatic"
Start-Service WinRM
Invoke-WebRequest -Uri https://get.mirantis.com/install.ps1 -o c:/install.ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force -Scope Process;
c:/install.ps1
Start-Sleep -s 5
Restart-Computer
EOF
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = {
    Name          = format("%s-win-vm-%s", var.name, count.index + 1)
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "instance"
    role          = "win-worker"
  }
}

resource "azurerm_virtual_machine_extension" "startup" {
  count                = var.win_worker_count
  name                 = format("%s%03d", "win-worker-", (count.index + 1))
  virtual_machine_id   = element(azurerm_virtual_machine.cso_win_vm.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/install.ps1; c:/azuredata/install.ps1\""
  }
SETTINGS
}
