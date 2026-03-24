resource "azapi_resource" "access_policy_assignment" {
  for_each = var.access_policy_assignments

  name      = each.value.object_id
  parent_id = azapi_resource.database.id
  type      = "Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2025-07-01"
  body = {
    properties = {
      accessPolicyName = each.value.access_policy_name
      user = {
        objectId = each.value.object_id
      }
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
