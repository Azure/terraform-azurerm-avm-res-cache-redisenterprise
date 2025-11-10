resource "azapi_resource" "redis" {
  type = "Microsoft.Cache/redis@2024-03-01"
  body = {
    properties = {
      enableNonSslPort    = var.enable_non_ssl_port
      minimumTlsVersion   = var.minimum_tls_version
      publicNetworkAccess = var.public_network_access
      redisConfiguration = var.redis_configuration != null ? {
        maxmemory-policy                  = var.redis_configuration.maxmemory_policy
        maxmemory-reserved                = var.redis_configuration.maxmemory_reserved != null ? tostring(var.redis_configuration.maxmemory_reserved) : null
        maxmemory-delta                   = var.redis_configuration.maxmemory_delta != null ? tostring(var.redis_configuration.maxmemory_delta) : null
        maxfragmentationmemory-reserved   = var.redis_configuration.maxfragmentationmemory_reserved != null ? tostring(var.redis_configuration.maxfragmentationmemory_reserved) : null
        rdb-backup-enabled                = var.redis_configuration.rdb_backup_enabled != null ? tostring(var.redis_configuration.rdb_backup_enabled) : null
        rdb-backup-frequency              = var.redis_configuration.rdb_backup_frequency != null ? tostring(var.redis_configuration.rdb_backup_frequency) : null
        rdb-backup-max-snapshot-count     = var.redis_configuration.rdb_backup_max_snapshot_count != null ? tostring(var.redis_configuration.rdb_backup_max_snapshot_count) : null
        rdb-storage-connection-string     = var.redis_configuration.rdb_storage_connection_string
        aof-backup-enabled                = var.redis_configuration.aof_backup_enabled != null ? tostring(var.redis_configuration.aof_backup_enabled) : null
        "aof-storage-connection-string-0" = var.redis_configuration.aof_storage_connection_string_0
        "aof-storage-connection-string-1" = var.redis_configuration.aof_storage_connection_string_1
        "authnotrequired"                 = var.redis_configuration.authentication_enabled ? null : "true"
      } : null
      replicasPerMaster  = var.replicas_per_master
      replicasPerPrimary = var.replicas_per_primary
      shardCount         = var.shard_count
      sku = {
        name     = var.sku_name
        family   = var.family
        capacity = var.capacity
      }
      staticIP       = var.static_ip
      subnetId       = var.subnet_id
      tenantSettings = var.tenant_settings
    }
    zones = var.zones
  }
  location               = var.location
  name                   = var.name
  parent_id              = var.resource_group_id
  response_export_values = ["*"]
  tags                   = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
