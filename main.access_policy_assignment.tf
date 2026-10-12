resource "azapi_resource" "access_policy_assignment" {
  for_each = var.access_policy_assignments

  # uuidv5 requires a namespace; "dns" is Terraform's built-in deterministic namespace keyword.
  name      = coalesce(each.value.name, replace(uuidv5("dns", each.value.object_id), "-", ""))
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
  schema_validation_enabled = false
}
