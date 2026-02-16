# Note: This module deploys a single Azure Redis Enterprise cluster with its default database.

# Management lock on Redis Enterprise cluster
resource "azapi_resource" "management_lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Role assignments on Redis Enterprise cluster
resource "azapi_resource" "role_assignment" {
  for_each = var.role_assignments

  name      = uuidv5("dns", "${each.key}-${each.value.principal_id}-${each.value.role_definition_id_or_name}")
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      roleDefinitionId                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : "${azapi_resource.this.id}/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id_or_name}"
      principalId                        = each.value.principal_id
      description                        = try(each.value.description, null)
      condition                          = try(each.value.condition, null)
      conditionVersion                   = try(each.value.condition_version, null)
      delegatedManagedIdentityResourceId = try(each.value.delegated_managed_identity_resource_id, null)
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
