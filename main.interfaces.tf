module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.9.0"

  location         = var.location
  enable_telemetry = var.enable_telemetry
  private_endpoints = {
    for key, endpoint in var.private_endpoints : key => merge(endpoint, {
      lock = endpoint.lock != null ? (endpoint.lock.kind == "None" ? null : endpoint.lock) : var.lock
      role_assignments = {
        for assignment_key, assignment in endpoint.role_assignments : assignment_key => merge(assignment, {
          role_definition_id_or_name = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.role_definition_id_or_name)) ? "/subscriptions/${provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${assignment.role_definition_id_or_name}" : assignment.role_definition_id_or_name
        })
      }
    })
  }
  private_endpoints_scope          = azapi_resource.this.id
  role_assignment_definition_scope = var.parent_id
}
