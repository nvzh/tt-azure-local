# tt-azure-tmp
### To Do
- Add NFS VM
- Add MSR 3.0.x 
- Change outdated "azurerm_virtual_machine" resource to "azurerm_linux(windows)_virtual_machine"
- Get rid of "--force-minimums" flag in MKE config
- Load Balancer doesn't route requests
- ~~DNS names instead of IPs~~
- ~~Integrate Azure project to Arif's TerraTrain~~
- ~~Change "subscription_id" and "tenant_id" to variables~~

### Known Issues
- Windows VM fails to spin up if cluster has MSR worker (Azure module)
- WinRM without IP in launchpad.yaml (AWS module)
- ~~Durin creation of a cluster in AWS some Azure objects are being created (rg, sa, sg, net, etc.)~~