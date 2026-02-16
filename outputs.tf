output "database" {
  description = "The Redis Enterprise database resource."
  value       = azapi_resource.database
}

output "database_id" {
  description = "The resource ID of the Redis Enterprise database."
  value       = azapi_resource.database.id
}

output "hostname" {
  description = "The hostname of the Redis Enterprise cluster."
  value       = azapi_resource.this.output.properties.hostName
}

output "name" {
  description = "The name of the Redis Enterprise cluster."
  value       = azapi_resource.this.name
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = azapi_resource.this_private_endpoint
}

output "redis_version" {
  description = "The Redis version of the cluster."
  value       = try(azapi_resource.this.output.properties.redisVersion, null)
}

output "resource" {
  description = "The Redis Enterprise cluster resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Redis Enterprise cluster."
  value       = azapi_resource.this.id
}
