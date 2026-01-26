variable "managed_redis_databases" {
  type = map(object({
    sku_name            = string
    enable_non_ssl_port = optional(bool, false)
    minimum_tls_version = optional(string, "1.2")
    clustering_policy   = optional(string, "EnterpriseCluster")
    eviction_policy     = optional(string, "AllKeysLRU")
    redis_modules = optional(list(object({
      name = string
      args = optional(string)
    })), [])
    tags = optional(map(string))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
Map of Azure Managed Redis cache instances.

Each database object supports the following attributes:

**Required:**
- `sku_name` - The SKU name of Azure Managed Redis. Examples:
  - Memory-Optimized: Memory-Optimized_M10, Memory-Optimized_M20
  - Balanced: Balanced_B0, Balanced_B1, Balanced_B3, Balanced_B5
  - Compute-Optimized: Compute-Optimized_X5, Compute-Optimized_X10

**Optional:**
- `enable_non_ssl_port` - Enable non-SSL port (6379). Default: false
- `minimum_tls_version` - Minimum TLS version. Default: "1.2"
- `clustering_policy` - Clustering policy: EnterpriseCluster (single endpoint, default), OSSCluster (Redis Cluster API, best performance), or NoEviction (non-clustered, ≤25GB). Default: "EnterpriseCluster"
- `eviction_policy` - Eviction policy: AllKeysLRU (default), AllKeysRandom, VolatileLRU, VolatileRandom, VolatileTTL, NoEviction
- `redis_modules` - List of Redis modules to enable (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries). Note: RediSearch requires EnterpriseCluster policy
- `tags` - Tags to assign to the Redis cache instance
- `timeouts` - Resource operation timeouts

**Example:**
```hcl
managed_redis_databases = {
  primary = {
    sku_name            = "Balanced_B0"
    minimum_tls_version = "1.2"
    enable_non_ssl_port = false
    clustering_policy   = "OSSCluster"  # For best performance
    eviction_policy     = "AllKeysLRU"
    redis_modules = [
      {
        name = "RedisJSON"
      },
      {
        name = "RediSearch"
      }
    ]
  }
}
```
DESCRIPTION
  nullable    = false
}
