data "azuread_client_config" "current" {}

# Dynamic group creation for EntraID (Azure AD) using Terraform.
# for department that change frequently, we can use dynamic blocks to create groups based on the unique departments in the users.csv file.
resource "azuread_group" "hr" {
  display_name     = "HR"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  #   types            = ["DynamicMembership"]

  #   dynamic_membership {
  #     enabled = true
  #     rule    = "user.department -eq \"HR\""
  #   }
}

resource "azuread_group" "marketing" {
  display_name     = "Marketing"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  #   types            = ["DynamicMembership"]

  #   dynamic_membership {
  #     enabled = true
  #     rule    = "user.department -eq \"Marketing\""
  #   }
}

resource "azuread_group" "sales" {
  display_name     = "Sales"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  #   types            = ["DynamicMembership"]

  #   dynamic_membership {
  #     enabled = true
  #     rule    = "user.department -eq \"Sales\""
  #   }
}

resource "azuread_group" "it" {
  display_name     = "IT"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  #   types            = ["DynamicMembership"]

  #   dynamic_membership {
  #     enabled = true
  #     rule    = "user.department -eq \"IT\""
  #   }
}

# Static group creation for users with 
# specific job titles, such as "Manager" or "Director". This allows us to create groups that are not 
# based on dynamic rules but rather on specific attributes of the users.
resource "azuread_group" "security" {
  display_name     = "Security"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "devops" {
  display_name     = "DevOps"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_group" "ciso" {
  display_name     = "CISO"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
}