# Configure Terraform
terraform {
  required_providers {
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