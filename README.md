# Infrastructure as Code

This repository contains Terraform configuration for provisioning a small Azure environment and a Linux virtual machine.

## What This Repo Deploys

The Terraform in [`azure/main.tf`](/abs/path/c:/infrastructure_as_code/azure/main.tf:1) creates:

- An Azure resource group in `eastus`
- A virtual network and subnet
- A network security group with inbound SSH access on port `22`
- A static public IP and network interface
- An Ubuntu 22.04 Linux virtual machine
- A Terraform output for the VM public IP address

The VM uses cloud-init style custom data from `azure/customdata.tpl` and runs a post-provision `local-exec` SSH script template selected by the `vm_os` variable.

## Repository Layout

- `azure/main.tf` - main Azure infrastructure definition
- `azure/variable.tf` - input variables
- `azure/userProvision.tf` - reserved for additional provisioning logic
- `azure/customdata.tpl` - VM custom data template
- `azure/windows-ssh-script.tpl` - Windows-oriented SSH helper template
- `azure/terraform_command.txt` - Terraform command notes
- `.gitignore` - ignores Terraform state, cache, and local config files

## Prerequisites

Before running Terraform, make sure you have:

- Terraform installed
- An Azure account and permission to create resources
- Azure authentication configured locally
- An SSH key pair available at `~/.ssh/azurekey` and `~/.ssh/azurekey.pub`

This configuration currently pins the AzureRM provider to `4.1.0`.

## How To Use

From the repo root:

```powershell
cd azure
terraform fmt
terraform init
terraform plan
terraform apply
```

Useful follow-up commands:

```powershell
terraform output
terraform state list
terraform destroy
```

## Current Configuration Notes

- The provider configuration includes a hardcoded Azure subscription ID.
- The VM admin username is set to `adminuser`.
- The VM size is `Standard_F2`.
- The default `vm_os` variable value is `windows`, which only affects the provisioner script interpreter selection. The machine itself is still a Linux VM.
- The SSH public key path is referenced directly from the local machine running Terraform.

## Caution

Review the Terraform files before applying in a shared or production subscription. The current configuration is suitable as a learning or lab environment and may need cleanup before broader use, especially around:

- Hardcoded identifiers and names
- Open SSH access from any source
- Local-machine-specific file paths
- Missing environment-specific variable files
