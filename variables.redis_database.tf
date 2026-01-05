variable "managed_redis_databases" {
  type = map(object({
    sku_name            = string
    enable_non_ssl_port = optional(bool, false)
    minimum_tls_version = optional(string, "1.2")
    tags                = optional(map(string))
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
- `tags` - Tags to assign to the Redis cache instance
- `timeouts` - Resource operation timeouts

**Example:**
```hcl
managed_redis_databases = {
  primary = {
    sku_name            = "Balanced_B0"
    minimum_tls_version = "1.2"
    enable_non_ssl_port = false
  }
}
```
DESCRIPTION
  nullable    = false
}
