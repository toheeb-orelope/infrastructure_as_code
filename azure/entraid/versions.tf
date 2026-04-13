# Configure Terraform
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
  }
}



provider "azurerm" {
  features {}
  # subscription_id = "fac7c7e0-b3f6-4b53-b639-a5c7d56e9952"

}

# Configure the Azure Active Directory Provider
provider "azuread" {
  # tenant_id = "f52a1935-4e59-4af8-9c2f-e4e055cb367d"
}
