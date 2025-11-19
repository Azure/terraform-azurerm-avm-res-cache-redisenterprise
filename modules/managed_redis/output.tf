output "resource_id" {
  description = "The resource ID of the Redis Enterprise cluster."
  value       = azapi_resource.cluster.id
}

output "database_id" {
  description = "The resource ID of the Redis Enterprise database."
  value       = azapi_resource.database.id
}

output "hostname" {
  description = "The hostname of the Redis Enterprise database."
  value       = azapi_resource.cluster.output.properties.hostName
}

output "resource" {
  description = "The full Redis Enterprise cluster resource."
  value       = azapi_resource.cluster
}

output "database" {
  description = "The full Redis Enterprise database resource."
  value       = azapi_resource.database
}
