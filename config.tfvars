# Cloud Provide Info
cloud_provider="azure"
# azure: germanywestcentral
region="germanywestcentral"              # AWS region : eu-central-1, ap-southeast-1, us-east-1 etc
caseNo="12345678"                    # optional tag to identify resources
# The 'name' mast be deleted
name="onovozhylov"

# Platform Info
# azure: UbuntuServer
os_name="UbuntuServer"                   # use "ubuntu" or  "redhat" or "centos"
# azure: 18.04-LTS
os_version="18.04-LTS"                 # for ubuntu 16.04,18.04 ... For redhat 7.8, 7.1, 8.1 ...
mcr_version="20.10.7"              # Please use specific minor engine version.

# MKE Info
manager_count="1"                  # Number of Managers
mke_version="3.5.2"                # MKE Version

# MSR Info
msr_count="1"                      # Number of MSR replicas
msr_version="2.9.5"                # For MSR Classic: 2.8.8, 2.9.7 etc. For MSRv3 choose the helm chart version 1.0.0,1.0.1 etc.
nfs_backend="0"                    # "1" for true and "0" for false, BUT: always put "1" for MSRv3, because we must have NFS for MSR3
msr_version_3="0"                  # Put 1 for MSR version 3

# Worker Info
worker_count="1"
win_worker_count="0"

#---------------------------------------------------------------------------------------------
# Advanced and Beta config
#manager_instance_type="c4.xlarge"
#msr_instance_type="c4.xlarge"
#worker_instance_type="c4.xlarge"
#win_worker_instance_type="c4.xlarge"
image_repo="docker.io/mirantis"    #For other repos. E.g, docker.io/mirantiseng
#registry_id=""
#registry_pass=""
#---------------------------------------------------------------------------------------------

# Check Again Please

# Following lines are autogenerated so please don't change
#---------------------------------------------------------------------------------------------