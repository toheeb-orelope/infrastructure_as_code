# Retrive current subscription information
data "azurerm_subscription" "current" {}

# Create resource group for Sentinel
resource "azurerm_resource_group" "RG-Sentinel-PoC" {
  name     = "RG-Sentinel-PoC"
  location = "eastus"
}


# Create log analytics workspace for Sentinel
resource "azurerm_log_analytics_workspace" "law-sentinel" {
  name                = "LAW-Sentinel-CloudScale"
  location            = azurerm_resource_group.RG-Sentinel-PoC.location
  resource_group_name = azurerm_resource_group.RG-Sentinel-PoC.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Enable Sentinel
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.law-sentinel.id
}

# Connect Defender
resource "azurerm_security_center_workspace" "defender-connection" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.law-sentinel.id
}


# Entra ID logs to Log Analytics
resource "azurerm_monitor_aad_diagnostic_setting" "entra_logs" {
  name                       = "entra-to-law"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law-sentinel.id


  enabled_log {
    category = "AuditLogs"
    retention_policy {
      enabled = false # Use workspace's retention settings
      days    = 0
    }
  }

  enabled_log {
    category = "SignInLogs"
    retention_policy {
      enabled = false # Use workspace's retention settings
      days    = 0
    }
  }
}

# Azure Activity logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "activity_logs" {
  name                       = "activity-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law-sentinel.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Security"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "ServiceHealth"
  }

  enabled_log {
    category = "ResourceHealth"
  }
}