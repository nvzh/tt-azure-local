variable "region" {
  type        = string
  description = "This is where you have to mention region"
  default = "germanywestcentral"
}
variable "client_id" {
  type = string
  sensitive = true
}
variable "client_secret" {
  type = string
  sensitive = true
}
variable "subscription_id" {
  type = string
  sensitive = true
}
variable "tenant_id" {
  type = string
  sensitive = true
}
variable "name" {
  type        = string
  description = "Please Type your name so that You and Cloud admin can identify your resources."
}
variable "caseNo" {
  type        = string
  description = "This is the case number to track the issue."
  default = "0"
}
variable "os_name" {
  type        = string
  description = "Please type os name like the following, \nUbuntuServer\nredhat\ncentos\nsuse"
  default = "UbuntuServer"
}
variable "os_version" {
  type        = string
  description = "Please type os Version. For ubuntu 16.04-LTS,18,04-LTS etc. For redhat 7.8, 7.1, 8.1 etc"
  default = "18.04-LTS"
}
variable "worker_count" {
  type        = string
  description = "Please type the total number of worker"
  default = 0
}
variable "manager_count" {
  type        = string
  description = "Please type the total number of manager"
  default = 1
}
variable "msr_count" {
  type        = string
  description = "Please type the total number of dtr"
  default = 0
}
variable "msr_version_3" {
  type        = string
  description = "Please type 1 if you need MSRv3"
  default = 0
}
variable "win_worker_count" {
  type        = string
  description = "Please type the total number of Windows worker"
  default = 0
}
variable "msr_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "manager_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "win_worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D4s_v3"
}
variable "image_repo" {
  type        = string
  default = "docker.io/mirantis"
}
variable "mcr_version" {
  type        = string
  description = "Please type your desired Mirantis Container Runtime version"
  default = "20.10.10"
}
variable "mke_version" {
  type        = string
  description = "Please type your desired Mirantis Kubernetes Engine version"
  default = "3.5.2"
}
variable "msr_version" {
  type        = string
  description = "Please type your desired Mirantis Secure Registry version"
}
variable "nfs_backend" {
  type        = string
  default = "0"
}