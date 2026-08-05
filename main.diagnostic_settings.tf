resource "azapi_resource" "diagnostic_settings" {
  for_each = local.diagnostic_settings

  name                      = each.value.name
  parent_id                 = azapi_resource.this.id
  type                      = local.diagnostic_settings_type
  body                      = each.value.body
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

resource "azapi_resource" "database_diagnostic_settings" {
  for_each = local.database_diagnostic_settings

  name                      = each.value.name
  parent_id                 = azapi_resource.database.id
  type                      = local.diagnostic_settings_type
  body                      = each.value.body
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
