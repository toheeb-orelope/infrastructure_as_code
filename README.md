# Infrastructure as Code

This repository contains Terraform configurations for three Azure-focused areas:

- `azure/compute-network` for Azure infrastructure and a Linux VM
- `azure/entraid` for Microsoft Entra ID users, groups, memberships, and Azure RBAC assignments
- `azure/sentinel` for Microsoft Sentinel onboarding, data collection, analytics, and automation

## Repository Structure

- `azure/compute-network` - Azure resource group, network, NSG, public IP, NIC, and Linux VM
- `azure/entraid` - Entra ID users, groups, group membership assignments, and role assignments
- `azure/sentinel` - Sentinel workspace onboarding, log ingestion, analytics rules, and playbook automation rules
- `.gitignore` - root ignore rules for Terraform cache, state, and local config files

## Module Overview

### `azure/compute-network`

This module provisions:

- A resource group in `eastus`
- A virtual network and subnet
- A network security group with inbound SSH on port `22`
- A static public IP
- A network interface
- An Ubuntu 22.04 Linux VM
- An output exposing the VM public IP

Relevant files:

- `azure/compute-network/main.tf`
- `azure/compute-network/variable.tf`
- `azure/compute-network/customdata.tpl`
- `azure/compute-network/windows-ssh-script.tpl`
- `azure/compute-network/userProvision.tf`
- `azure/compute-network/terraform_command.txt`

Important current settings:

- AzureRM provider version is pinned to `4.1.0`
- Subscription ID is hardcoded in `azure/compute-network/main.tf`
- VM size is `Standard_F2`
- Admin username is `adminuser`
- SSH key paths are expected at `~/.ssh/azurekey` and `~/.ssh/azurekey.pub`
- `vm_os` defaults to `windows`, but that only controls the local provisioner interpreter; the deployed machine is still a Linux VM

### `azure/entraid`

This module manages identity resources using the `azuread` and `azurerm` providers.

It currently:

- Reads users from `users.csv`
- Looks up the tenant's initial domain
- Creates Entra ID users in bulk
- Creates security groups including `HR`, `Marketing`, `Sales`, `IT`, `Security`, `DevOps`, and `CISO`
- Assigns users to groups using the current demo membership logic
- Assigns Azure subscription-level roles to those groups

Relevant files:

- `azure/entraid/versions.tf`
- `azure/entraid/main.tf`
- `azure/entraid/group.tf`
- `azure/entraid/group_members.tf`
- `azure/entraid/roles_ass.tf`
- `azure/entraid/users.csv`
- `azure/entraid/cmd.txt`

Important current settings:

- AzureAD provider version is constrained to `~> 3.1.0`
- AzureRM provider version is `4.1.0`
- Group membership assignment is demo-oriented and currently distributes users across groups by index
- `CISO` is assigned the `Contributor` role at subscription scope
- Other listed groups are assigned the `Reader` role at subscription scope

### `azure/sentinel`

This module configures a Microsoft Sentinel proof-of-concept environment.

It currently:

- Creates a resource group in `eastus`
- Creates a Log Analytics workspace
- Onboards that workspace to Microsoft Sentinel
- Connects Microsoft Defender for Cloud to the workspace
- Sends Entra ID audit and sign-in logs to Log Analytics
- Sends Azure Activity logs to Log Analytics
- Creates a scheduled Sentinel analytics rule for out-of-hours privileged role assignments
- Creates Sentinel automation rules that trigger a Logic App playbook when incidents are created

Relevant files:

- `azure/sentinel/main.tf`
- `azure/sentinel/automations.tf`
- `azure/sentinel/versions.tf`

Important current settings:

- AzureRM provider version is pinned to `4.1.0`
- The Log Analytics workspace name is `LAW-Sentinel-CloudScale`
- The Sentinel resource group name is `RG-Sentinel-PoC`
- The scheduled rule query looks for successful `Microsoft.Authorization/roleAssignments/write` activity outside business hours
- The automation rule uses a `condition_json` filter against `IncidentRelatedAnalyticRuleIds`
- The playbook target is a Logic App workflow named `OutOfHoursRole`
- Automation rule resource `name` values must be UUIDs, while readable labels belong in `display_name`

## Prerequisites

Before using any module, make sure you have:

- Terraform installed
- An Azure account with permission to manage the target subscription and tenant
- Azure authentication configured locally
- Permission to create Entra ID users, groups, and Azure role assignments
- Permission to create and manage Sentinel resources, diagnostic settings, and Logic App integrations

For `azure/compute-network`, you also need:

- An SSH key pair at `~/.ssh/azurekey` and `~/.ssh/azurekey.pub`

## How To Run

Run Terraform from inside the module you want to apply.

### Compute and network

```powershell
cd azure/compute-network
terraform fmt
terraform init
terraform plan
terraform apply
```

### Entra ID

```powershell
cd azure/entraid
terraform fmt
terraform init
terraform plan
terraform apply
```

### Sentinel

```powershell
cd azure/sentinel
terraform fmt
terraform init
terraform plan
terraform apply
```

Useful commands for either module:

```powershell
terraform output
terraform state list
terraform destroy
```

## Authentication Notes

The Entra ID folder includes command notes in `azure/entraid/cmd.txt` showing environment-variable based authentication examples for:

- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

Review and set credentials appropriately before running Terraform.

The Sentinel module also assumes:

- Access to the target Azure subscription
- A valid Logic App workflow already exists for the configured `logic_app_id`

## Caution

This repository appears suited for lab, learning, or internal demo use. Review the configuration before using it in a broader environment.

Current risks and cleanup items include:

- Hardcoded subscription-specific values
- Open SSH access from any source in the compute/network module
- Local-machine-specific SSH key paths
- Demo-style group membership logic in the Entra ID module
- Subscription-scope RBAC assignments
- Sentinel automation depends on an existing Logic App workflow path
- Sentinel and Entra ID Terraform state files are currently present under their module folders
