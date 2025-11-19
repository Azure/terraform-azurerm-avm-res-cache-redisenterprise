variable "managed_redis_databases" {
  type = map(object({
    sku_name              = string
    family                = optional(string)
    capacity              = optional(number)
    enable_non_ssl_port   = optional(bool, false)
    minimum_tls_version   = optional(string, "1.2")
    public_network_access = optional(string, "Enabled")
    redis_configuration = optional(object({
      maxmemory_policy                = optional(string)
      maxmemory_reserved              = optional(number)
      maxmemory_delta                 = optional(number)
      maxfragmentationmemory_reserved = optional(number)
      rdb_backup_enabled              = optional(bool)
      rdb_backup_frequency            = optional(number)
      rdb_backup_max_snapshot_count   = optional(number)
      rdb_storage_connection_string   = optional(string)
      aof_backup_enabled              = optional(bool)
      aof_storage_connection_string_0 = optional(string)
      aof_storage_connection_string_1 = optional(string)
      authentication_enabled          = optional(bool, true)
    }))
    replicas_per_master  = optional(number)
    replicas_per_primary = optional(number)
    shard_count          = optional(number)
    static_ip            = optional(string)
    subnet_id            = optional(string)
    tenant_settings      = optional(map(string))
    zones                = optional(list(string))
    tags                 = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  description = <<DESCRIPTION
Map of Azure Managed Redis cache instances.

Each database object supports the following attributes:

**Required:**
- `sku_name` - The SKU name of Azure Managed Redis. Examples:
  - Memory-Optimized: Memory-Optimized_M1, Memory-Optimized_M5, Memory-Optimized_M10
  - Balanced: Balanced_B1, Balanced_B5, Balanced_B10
  - Compute-Optimized: Compute-Optimized_C1, Compute-Optimized_C5

**Optional (most are deprecated for Azure Managed Redis):**
- `family` - DEPRECATED: Not used in Azure Managed Redis
- `capacity` - DEPRECATED: Not used in Azure Managed Redis
- `redis_configuration` - Redis configuration (mainly maxmemory_policy for Azure Managed Redis)

`redis_configuration` block supports:
- `maxmemory_policy` - The maxmemory policy for the Redis cache

NOTE: Azure Managed Redis is a simplified managed service with fewer configuration options than Azure Cache for Redis.
Most optional parameters are kept for backward compatibility but are not used.
DESCRIPTION

  default  = {}
  nullable = false
}
