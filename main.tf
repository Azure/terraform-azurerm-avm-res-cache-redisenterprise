# Note: This module deploys Azure Managed Redis instances (standalone cache service).

# Management lock on managed redis instances
resource "azurerm_management_lock" "this" {
  for_each = var.lock != null ? var.managed_redis_databases : {}

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}-${each.key}")
  scope      = azapi_resource.managed_redis_cluster[each.key].id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

# Role assignments on managed redis instances
resource "azurerm_role_assignment" "this" {
  for_each = {
    for pair in flatten([
      for redis_key in keys(var.managed_redis_databases) : [
        for role_key, role_value in var.role_assignments : {
          key       = "${redis_key}-${role_key}"
          redis_key = redis_key
          role      = role_value
        }
      ]
    ]) : pair.key => pair
  }

  principal_id                           = each.value.role.principal_id
  scope                                  = azapi_resource.managed_redis_cluster[each.value.redis_key].id
  condition                              = each.value.role.condition
  condition_version                      = each.value.role.condition_version
  delegated_managed_identity_resource_id = each.value.role.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.role.skip_service_principal_aad_check
}
