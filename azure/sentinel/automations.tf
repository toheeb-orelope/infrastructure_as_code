# Get tenant ID for automation rule
data "azurerm_client_config" "current" {}
# # Retrive current subscription information
# data "azurerm_subscription" "current" {}


# Analytics Rule (Scheduled)
resource "azurerm_sentinel_alert_rule_scheduled" "privileged_role_assignment_outside_hours" {
  name                       = "privileged-role-assignment-outside-hours"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
  display_name               = "Privileged Role Assignment Outside Business Hours"
  severity                   = "High"
  enabled                    = true

  query = <<-QUERY
    AzureActivity
    | where TimeGenerated > ago(5m)
    | where OperationNameValue =~ "Microsoft.Authorization/roleAssignments/write"
    | where ActivityStatusValue =~ "Success"
    | extend Hour = hourofday(TimeGenerated)
    | extend DayOfWeek = dayofweek(TimeGenerated)
    | where (Hour < 8 or Hour >= 18) or (DayOfWeek == 0d or DayOfWeek == 6d)
    | extend Role = tostring(parse_json(Properties).role)
    | extend PrincipalId = tostring(parse_json(Properties).principalId)
    | project TimeGenerated, Caller, Role, PrincipalId, ResourceGroup, SubscriptionId, Hour, DayOfWeek
  QUERY

  query_frequency = "PT5M"
  query_period    = "PT5M"

  suppression_duration = "PT5M"
  suppression_enabled  = false

  incident {
    create_incident_enabled = true

    grouping {
      enabled                 = true
      lookback_duration       = "PT5M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }

  entity_mapping {
    entity_type = "Account"

    field_mapping {
      identifier  = "FullName"
      column_name = "Caller"
    }
  }
}

# Automation Rule to trigger playbook when incident is created
resource "azurerm_sentinel_automation_rule" "trigger_playbook_on_incident" {
  name                       = "0f7c2d34-1f51-4a8d-9e2d-6c5a0d9b3e11"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
  display_name               = "Trigger Playbook for Privileged Role Assignments"
  order                      = 1
  enabled                    = true

  # Trigger when incident is created by ANY rule (or specific)
  triggers_on   = "Incidents"
  triggers_when = "Created"

  # Condition: Only for incidents with this specific analytics rule
  condition_json = jsonencode([
    {
      conditionType = "Property"
      conditionProperties = {
        propertyName = "IncidentRelatedAnalyticRuleIds"
        operator = "Contains"
        propertyValues = [
          azurerm_sentinel_alert_rule_scheduled.privileged_role_assignment_outside_hours.id
        ]
      }
    }
  ])

  # Action: Run the playbook
  action_playbook {
    logic_app_id = "${data.azurerm_subscription.current.id}/resourceGroups/RG-Sentinel-PoC/providers/Microsoft.Logic/workflows/OutOfHoursRole" # Update this
    order        = 1
    tenant_id    = data.azurerm_client_config.current.tenant_id
  }
}

# Simpler automation rule - triggers on all incidents
resource "azurerm_sentinel_automation_rule" "trigger_playbook_all_incidents" {
  name                       = "6a9e4a12-8c3b-4c71-b6d4-2f8e1a7c5d22"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.sentinel.workspace_id
  display_name               = "Trigger Playbook on All Incidents"
  order                      = 1
  enabled                    = true
  triggers_on                = "Incidents"
  triggers_when              = "Created"

  action_playbook {
    logic_app_id = "${data.azurerm_subscription.current.id}/resourceGroups/RG-Sentinel-PoC/providers/Microsoft.Logic/workflows/OutOfHoursRole"
    order        = 1
    tenant_id    = data.azurerm_client_config.current.tenant_id
  }
}

