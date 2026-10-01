resource "azapi_resource" "diagnostic_settings" {
  for_each = local.diagnostic_settings

  name                      = each.value.name
  parent_id                 = azapi_resource.this.id
  type                      = local.diagnostic_settings_type
  body                      = each.value.body
  schema_validation_enabled = false
}

resource "azapi_resource" "database_diagnostic_settings" {
  for_each = local.database_diagnostic_settings

  name                      = each.value.name
  parent_id                 = azapi_resource.database.id
  type                      = local.diagnostic_settings_type
  body                      = each.value.body
  schema_validation_enabled = false
}
