terraform {
  backend "local" {
    path = "../../terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
  }

  required_version = "~> 1.2.1"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

module "common" {
  source   = "./common"
  location = var.region
  name     = var.name
  caseNo   = var.caseNo
  rg       = module.vnet.rg
}

module "vnet" {
  source   = "./vnet"
  location = var.region
  name     = var.name
  caseNo   = var.caseNo
}

module "manager" {
  source                = "./manager"
  caseNo                = var.caseNo
  manager_count         = var.manager_count
  name                  = var.name
  location              = var.region
  manager_instance_type = var.manager_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "worker" {
  source                = "./worker"
  caseNo                = var.caseNo
  worker_count          = var.worker_count
  name                  = var.name
  location              = var.region
  worker_instance_type  = var.worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "msr-worker" {
  source                = "./msr-worker"
  caseNo                = var.caseNo
  msr_count             = var.msr_count
  name                  = var.name
  location              = var.region
  msr_instance_type     = var.msr_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "win-worker" {
  source                = "./win-worker"
  caseNo                = var.caseNo
  win_worker_count      = var.win_worker_count
  name                  = var.name
  location              = var.region
  win_worker_instance_type     = var.win_worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
  password          = module.common.password
}

module "nfs-node" {
  source                = "./nfs-node"
  caseNo                = var.caseNo
  nfs_backend           = var.nfs_backend
  name                  = var.name
  location              = var.region
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}