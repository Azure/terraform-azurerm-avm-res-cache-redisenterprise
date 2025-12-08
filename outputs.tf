output "resource_id" {
  description = "The resource ID of the primary Redis cache instance."
  value       = length(module.managed_redis) > 0 ? values(module.managed_redis)[0].resource_id : null
}

output "managed_redis_caches" {
  description = "A map of all Azure Managed Redis cache instances created by this module."
  value       = module.managed_redis
}

output "managed_redis_resource_ids" {
  description = "A map of Azure Managed Redis cache resource IDs."
  value = {
    for k, v in module.managed_redis : k => v.resource_id
  }
}

output "private_endpoints" {
  description = <<DESCRIPTION
  A map of the private endpoints created.
  DESCRIPTION
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this_managed_dns_zone_groups : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}
