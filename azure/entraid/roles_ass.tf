data "azurerm_subscription" "current" {}


# Roles assignment to the groups in Azure Active Directory.
resource "azurerm_role_assignment" "ciso_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.ciso.object_id
}

resource "azurerm_role_assignment" "security_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.security.object_id
}

resource "azurerm_role_assignment" "devops_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.devops.object_id
}

resource "azurerm_role_assignment" "it_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.it.object_id
}

resource "azurerm_role_assignment" "marketing_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.marketing.object_id
}

resource "azurerm_role_assignment" "sales_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.sales.object_id
}

resource "azurerm_role_assignment" "hr_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.hr.object_id
}
