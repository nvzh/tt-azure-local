# Creating two random password for MKE username and Password
resource "random_pet" "mke_username" {
  length  = 2
}

resource "random_string" "mke_password" {
  length  = 20
  min_upper = 5
  min_lower = 5
  min_numeric = 5
  special = false
}

# Storage account for MSR 3.x.x
resource "azurerm_storage_account" "cso_sa" {
  name                      = "case${var.caseNo}sa"
  resource_group_name       = var.rg
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"

  tags = {
    Name          = "${var.name}-storageAccount"
    resourceOwner = "${var.name}"
    caseNumber    = "${var.caseNo}"
    resourceType  = "storageAccount"
  }
}