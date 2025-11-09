variable "managed_redis_databases" {
  type = map(object({
    sku_name                = string
    family                  = string
    capacity                = number
    enable_non_ssl_port     = optional(bool, false)
    minimum_tls_version     = optional(string, "1.2")
    public_network_access   = optional(string, "Enabled")
    redis_configuration = optional(object({
      maxmemory_policy                     = optional(string)
      maxmemory_reserved                   = optional(number)
      maxmemory_delta                      = optional(number)
      maxfragmentationmemory_reserved      = optional(number)
      rdb_backup_enabled                   = optional(bool)
      rdb_backup_frequency                 = optional(number)
      rdb_backup_max_snapshot_count        = optional(number)
      rdb_storage_connection_string        = optional(string)
      aof_backup_enabled                   = optional(bool)
      aof_storage_connection_string_0      = optional(string)
      aof_storage_connection_string_1      = optional(string)
      authentication_enabled               = optional(bool, true)
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
- `sku_name` - The SKU name of the Redis cache. Possible values are Basic, Standard, Premium.
- `family` - The SKU family/pricing group. Valid values are C (Basic/Standard) and P (Premium).
- `capacity` - The size of the Redis cache to deploy. Valid values depend on the SKU family (0-6).

**Optional:**
- `enable_non_ssl_port` - Enable the non-SSL port (6379). Defaults to false.
- `minimum_tls_version` - The minimum TLS version. Possible values are 1.0, 1.1, 1.2. Defaults to 1.2.
- `public_network_access` - Whether public network access is allowed. Possible values are Enabled and Disabled. Defaults to Enabled.
- `replicas_per_master` - The number of replicas per master (deprecated, use replicas_per_primary).
- `replicas_per_primary` - The number of replicas per primary.
- `shard_count` - The number of shards to create on a Premium Cluster Cache.
- `static_ip` - The static IP address to assign to the Redis cache.
- `subnet_id` - The subnet ID for the Redis cache (Premium SKU only).
- `tenant_settings` - A mapping of tenant settings to assign to the resource.
- `zones` - A list of availability zones where the Redis cache should be located.
- `tags` - Tags to assign to the Redis cache.

`redis_configuration` block supports the following:
- `maxmemory_policy` - The maxmemory policy for the Redis cache.
- `maxmemory_reserved` - The maxmemory reserved value.
- `maxmemory_delta` - The maxmemory delta value.
- `maxfragmentationmemory_reserved` - The maxfragmentationmemory reserved value.
- `rdb_backup_enabled` - Indicates whether RDB backup is enabled (Premium SKU only).
- `rdb_backup_frequency` - The RDB backup frequency in minutes.
- `rdb_backup_max_snapshot_count` - The maximum number of RDB snapshots to keep.
- `rdb_storage_connection_string` - The storage connection string for RDB backups.
- `aof_backup_enabled` - Indicates whether AOF backup is enabled (Premium SKU only).
- `aof_storage_connection_string_0` - The first storage connection string for AOF backups.
- `aof_storage_connection_string_1` - The second storage connection string for AOF backups.
- `authentication_enabled` - Indicates whether authentication is enabled. Defaults to true.

`timeouts` block supports the following:
- `create` - Timeout for create operations.
- `delete` - Timeout for delete operations.
- `read` - Timeout for read operations.
- `update` - Timeout for update operations.
DESCRIPTION

  default  = {}
  nullable = false
}
