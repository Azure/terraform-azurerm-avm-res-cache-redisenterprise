# Redis Enterprise Cluster Configuration

variable "sku_name" {
  type        = string
  description = <<DESCRIPTION
The SKU name of Azure Managed Redis (Redis Enterprise). Examples:
- Memory-Optimized: Memory-Optimized_M10, Memory-Optimized_M20
- Balanced: Balanced_B0, Balanced_B1, Balanced_B3, Balanced_B5
- Compute-Optimized: Compute-Optimized_X5, Compute-Optimized_X10

**Example:**
```hcl
sku_name = "Balanced_B0"
```
DESCRIPTION
  nullable    = false
}

variable "access_keys_authentication_enabled" {
  type        = bool
  default     = false
  description = "Whether access key authentication is enabled for the Redis Enterprise database. Defaults to `false` so Microsoft Entra authentication can be used without key-based access."
  nullable    = false
}

variable "access_policy_assignments" {
  type = map(object({
    name               = optional(string)
    object_id          = string
    access_policy_name = optional(string, "default")
  }))
  default     = {}
  description = <<DESCRIPTION
Map of access policy assignments for the Redis Enterprise database. The map key is deliberately arbitrary to avoid issues where map keys may be unknown at plan time.

- `name` - (Optional) The name of the Redis Enterprise database access policy assignment. If omitted, a stable name is generated.
- `object_id` - (Required) The Microsoft Entra object ID of the principal to assign to the access policy. Pass a managed identity's `principal_id` here when assigning identity-based access.
- `access_policy_name` - (Optional) The Redis Enterprise database access policy name. Defaults to `default`.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, assignment in var.access_policy_assignments :
      assignment.name == null ? true : can(regex("^[A-Za-z0-9]{1,60}$", assignment.name))
    ])
    error_message = "Each access policy assignment `name`, when specified, must be 1-60 alphanumeric characters."
  }
}

variable "clustering_policy" {
  type        = string
  default     = "EnterpriseCluster"
  description = <<DESCRIPTION
Clustering policy for the Redis cache:
- `EnterpriseCluster` - Single endpoint, automatic sharding (default)
- `OSSCluster` - Redis Cluster API protocol, best performance
- `NoCluster` - Non-clustered mode, maximum 25GB

Default: "EnterpriseCluster"
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["EnterpriseCluster", "OSSCluster", "NoCluster"], var.clustering_policy)
    error_message = "Clustering policy must be one of: EnterpriseCluster, OSSCluster, NoCluster"
  }
}

variable "customer_managed_key_encryption" {
  type = object({
    key_encryption_key_url             = string
    identity_type                      = string
    user_assigned_identity_resource_id = optional(string)
  })
  default     = null
  description = "Optional customer-managed key encryption settings for the Redis Enterprise cluster."
}

variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "Enable non-SSL port (6379) for Redis cache. Default: false (SSL only)."
  nullable    = false
}

variable "eviction_policy" {
  type        = string
  default     = "AllKeysLRU"
  description = <<DESCRIPTION
Eviction policy when maximum memory is reached:
- `AllKeysLRU` - Remove least recently used keys (default)
- `AllKeysRandom` - Remove random keys
- `VolatileLRU` - Remove least recently used keys with expiration set
- `VolatileRandom` - Remove random keys with expiration set
- `VolatileTTL` - Remove keys with shortest time to live
- `NoEviction` - Return errors when memory limit is reached

Default: "AllKeysLRU"
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["AllKeysLRU", "AllKeysRandom", "VolatileLRU", "VolatileRandom", "VolatileTTL", "NoEviction"], var.eviction_policy)
    error_message = "Eviction policy must be one of: AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileRandom, VolatileTTL, NoEviction"
  }
}

variable "geo_replication" {
  type = object({
    group_nickname = string
    linked_databases = optional(set(object({
      id = string
    })), [])
  })
  default     = null
  description = "Optional geo-replication settings for the Redis Enterprise database."
}

variable "high_availability" {
  type        = string
  default     = null
  description = "Optional high availability mode for the Redis Enterprise cluster."
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identity configuration for the Redis Enterprise cluster."
  nullable    = false
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version for Redis cache connections. Possible values: 1.0, 1.1, 1.2. Default: 1.2"
  nullable    = false

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2"
  }
}

variable "persistence" {
  type = object({
    aof_enabled   = optional(bool, false)
    aof_frequency = optional(string, "1s")
    rdb_enabled   = optional(bool, false)
    rdb_frequency = optional(string, "12h")
  })
  default     = null
  description = <<DESCRIPTION
Optional persistence settings for the Redis Enterprise database.

- `aof_enabled` - (Optional) Whether Append Only File (AOF) persistence is enabled. Defaults to `false`.
- `aof_frequency` - (Optional) The frequency at which AOF data is written to disk. Possible values are `1s` and `always`. Defaults to `1s`.
- `rdb_enabled` - (Optional) Whether Redis Database (RDB) persistence is enabled. Defaults to `false`.
- `rdb_frequency` - (Optional) The frequency at which an RDB snapshot is created. Possible values are `1h`, `6h`, and `12h`. Defaults to `12h`.
DESCRIPTION

  validation {
    condition     = var.persistence == null ? true : !(var.persistence.aof_enabled && var.persistence.rdb_enabled)
    error_message = "AOF and RDB persistence are mutually exclusive. Only one may be enabled at a time."
  }
  validation {
    condition     = var.persistence == null ? true : contains(["1s", "always"], var.persistence.aof_frequency)
    error_message = "AOF frequency must be one of: 1s, always."
  }
  validation {
    condition     = var.persistence == null ? true : contains(["1h", "6h", "12h"], var.persistence.rdb_frequency)
    error_message = "RDB frequency must be one of: 1h, 6h, 12h."
  }
}

variable "public_network_access" {
  type        = string
  default     = "Disabled"
  description = <<DESCRIPTION
Controls public network access for the Redis Enterprise cluster:
- `Enabled` - Allow public network access
- `Disabled` - Deny public network access, use private endpoints only (default)

Default: "Disabled"
DESCRIPTION
  nullable    = false

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "Public network access must be either 'Enabled' or 'Disabled'"
  }
}

variable "redis_modules" {
  type = list(object({
    name = string
    args = optional(string)
  }))
  default     = []
  description = <<DESCRIPTION
List of Redis modules to enable:
- `RediSearch` - Full-text search (requires EnterpriseCluster policy)
- `RedisJSON` - JSON data type support
- `RedisBloom` - Probabilistic data structures
- `RedisTimeSeries` - Time series data structures

**Example:**
```hcl
redis_modules = [
  {
    name = "RedisJSON"
  },
  {
    name = "RediSearch"
  }
]
```
DESCRIPTION
  nullable    = false
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = "Timeouts for Redis Enterprise cluster and database operations."
}

variable "zones" {
  type        = set(string)
  default     = []
  description = "Optional set of availability zones for the Redis Enterprise cluster."
  nullable    = false
}
