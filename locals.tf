locals {
  database_diagnostic_settings = {
    for key, value in var.database_diagnostic_settings : key => {
      name = value.name != null ? value.name : "diag-${var.name}-database"
      body = {
        properties = {
          eventHubAuthorizationRuleId = value.event_hub_authorization_rule_resource_id
          eventHubName                = value.event_hub_name
          logAnalyticsDestinationType = value.log_analytics_destination_type
          logs = concat(
            [
              for log_group in value.log_groups : {
                category      = null
                categoryGroup = log_group
                enabled       = true
              }
            ],
            [
              for log_category in value.log_categories : {
                category      = log_category
                categoryGroup = null
                enabled       = true
              }
            ]
          )
          marketplacePartnerId = value.marketplace_partner_resource_id
          metrics = length(value.metric_categories) > 0 ? [
            for category in value.metric_categories : {
              category = category
              enabled  = true
            }
          ] : null
          storageAccountId = value.storage_account_resource_id
          workspaceId      = value.workspace_resource_id
        }
      }
    }
  }
  diagnostic_settings = {
    for key, value in var.diagnostic_settings : key => {
      name = value.name != null ? value.name : "diag-${var.name}"
      body = {
        properties = {
          eventHubAuthorizationRuleId = value.event_hub_authorization_rule_resource_id
          eventHubName                = value.event_hub_name
          logAnalyticsDestinationType = value.log_analytics_destination_type
          logs = concat(
            [
              for log_group in value.log_groups : {
                category      = null
                categoryGroup = log_group
                enabled       = true
              }
            ],
            [
              for log_category in value.log_categories : {
                category      = log_category
                categoryGroup = null
                enabled       = true
              }
            ]
          )
          marketplacePartnerId = value.marketplace_partner_resource_id
          metrics = length(value.metric_categories) > 0 ? [
            for category in value.metric_categories : {
              category = category
              enabled  = true
            }
          ] : null
          storageAccountId = value.storage_account_resource_id
          workspaceId      = value.workspace_resource_id
        }
      }
    }
  }
  diagnostic_settings_type = "Microsoft.Insights/diagnosticSettings@2021-05-01-preview"
  # Private endpoint application security group associations.
  # We merge the nested maps from private endpoints and application security group associations into a single map.
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
