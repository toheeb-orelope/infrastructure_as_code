
# Retrieve domain information
data "azuread_domains" "domains" {
  only_initial = true
}


locals {
  domain_name = data.azuread_domains.domains.domains[0].domain_name

  users = csvdecode(file("${path.module}/users.csv"))
  users_by_upn = {
    for user in local.users :
    "${lower(user.first_name)}.${lower(user.last_name)}@${local.domain_name}" => user
  }
}

resource "azuread_user" "bulk_users" {
  for_each = local.users_by_upn

  user_principal_name = each.key
  display_name        = "${each.value.first_name} ${each.value.last_name}"
  mail_nickname       = lower(replace("${each.value.first_name}.${each.value.last_name}", " ", ""))
  given_name          = each.value.first_name
  surname             = each.value.last_name
  department          = each.value.department
  job_title           = each.value.job_title
  password            = each.value.password

  force_password_change = true
  account_enabled       = lower(each.value.account_enabled) == "true"
}