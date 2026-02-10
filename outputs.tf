output "resource" {
  description = "The Redis Enterprise cluster resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Redis Enterprise cluster."
  value       = azapi_resource.this.id
}

output "database" {
  description = "The Redis Enterprise database resource."
  value       = azapi_resource.database
}

output "database_id" {
  description = "The resource ID of the Redis Enterprise database."
  value       = azapi_resource.database.id
}

output "name" {
  description = "The name of the Redis Enterprise cluster."
  value       = azapi_resource.this.name
}

output "hostname" {
  description = "The hostname of the Redis Enterprise cluster."
  value       = jsondecode(azapi_resource.this.output).properties.hostName
}

output "redis_version" {
  description = "The Redis version of the cluster."
  value       = try(jsondecode(azapi_resource.this.output).properties.redisVersion, null)
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}
