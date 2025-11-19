module "managed_redis" {
  source   = "./modules/managed_redis"
  for_each = var.managed_redis_databases

  name              = "${var.name}-${each.key}"
  location          = var.location
  resource_group_id = var.resource_group_id

  sku_name = each.value.sku_name
  family   = each.value.family
  capacity = each.value.capacity

  enable_non_ssl_port   = try(each.value.enable_non_ssl_port, false)
  minimum_tls_version   = try(each.value.minimum_tls_version, "1.2")
  public_network_access = try(each.value.public_network_access, "Enabled")
  redis_configuration   = try(each.value.redis_configuration, null)
  replicas_per_master   = try(each.value.replicas_per_master, null)
  replicas_per_primary  = try(each.value.replicas_per_primary, null)
  shard_count           = try(each.value.shard_count, null)
  static_ip             = try(each.value.static_ip, null)
  subnet_id             = try(each.value.subnet_id, null)
  tenant_settings       = try(each.value.tenant_settings, null)
  zones                 = try(each.value.zones, null)
  tags                  = try(each.value.tags, var.tags)

  timeouts = try(each.value.timeouts, null)
}
