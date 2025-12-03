module "managed_redis" {
  source   = "./modules/managed_redis"
  for_each = var.managed_redis_databases

  name              = "${var.name}-${each.key}"
  location          = var.location
  resource_group_id = var.resource_group_id

  sku_name            = each.value.sku_name
  enable_non_ssl_port = try(each.value.enable_non_ssl_port, false)
  minimum_tls_version = try(each.value.minimum_tls_version, "1.2")
  tags                = try(each.value.tags, var.tags)
  timeouts            = try(each.value.timeouts, null)
}
