# Creating group members for the bulk users in Azure Active Directory.
locals {
  user_list = [
    for upn, user in azuread_user.bulk_users :
    {
      upn       = upn
      object_id = user.object_id
    }
  ]
}

# Assign user randomly to groups
locals {
  groups = [
    azuread_group.hr.object_id,
    azuread_group.marketing.object_id,
    azuread_group.sales.object_id,
    azuread_group.it.object_id,
    azuread_group.security.object_id,
    azuread_group.devops.object_id,
    azuread_group.ciso.object_id
  ]

  assignments = {
    for idx, user in local.user_list :
    idx => {
      user_id  = user.object_id
      group_id = local.groups[idx % length(local.groups)]
    }
  }
}

# Create group memberships
resource "azuread_group_member" "random_members" {
  for_each = local.assignments

  group_object_id  = each.value.group_id
  member_object_id = each.value.user_id
}

# The above code is suited for demo
# But in a production environment, you would typically want to assign users to groups based on 
# specific attributes or roles rather than randomly. You can modify the logic in the 
# `assignments` local variable to assign users to groups based on their department, 
# job title, or any other relevant attribute.
# For example, a sensitive group like "CISO" could be created for users with the job title "Chief Information Security Officer".

# resource "azuread_group_member" "ciso_member" {
#   group_object_id  = azuread_group.ciso.object_id
#   member_object_id = values(azuread_user.bulk_users)[0].object_id
# }