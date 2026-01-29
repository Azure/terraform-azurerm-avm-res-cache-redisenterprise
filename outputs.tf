output "managed_redis_caches" {
  description = "A map of all Azure Managed Redis cache instances created by this module."
  value = {
    for k, v in azapi_resource.managed_redis_cluster : k => {
      cluster     = v
      database    = azapi_resource.managed_redis_database[k]
      database_id = azapi_resource.managed_redis_database[k].id
      hostname    = v.output.properties.hostName
      resource    = v
      resource_id = v.id
    }
  }
}

output "managed_redis_resource_ids" {
  description = "A map of Azure Managed Redis cache resource IDs."
  value = {
    for k, v in azapi_resource.managed_redis_cluster : k => v.id
  }
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "resource_id" {
  description = "The resource ID of the primary Redis cache instance."
  value       = length(azapi_resource.managed_redis_cluster) > 0 ? values(azapi_resource.managed_redis_cluster)[0].id : null
}
