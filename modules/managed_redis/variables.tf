variable "name" {
  type        = string
  description = "The name of the Azure Managed Redis cache."

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name))
    error_message = "The name must be between 1 and 63 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the Redis cache will be deployed."
  nullable    = false
}

variable "resource_group_id" {
  type        = string
  description = "The resource ID of the resource group."
  nullable    = false
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the Redis cache. Possible values are Basic, Standard, Premium."
  nullable    = false

  validation {
    condition     = can(regex("^(Basic|Standard|Premium)$", var.sku_name))
    error_message = "The SKU name must be one of 'Basic', 'Standard', or 'Premium'."
  }
}

variable "family" {
  type        = string
  description = "The SKU family/pricing group. Valid values are C (Basic/Standard) and P (Premium)."
  nullable    = false

  validation {
    condition     = can(regex("^(C|P)$", var.family))
    error_message = "The family must be either 'C' or 'P'."
  }
}

variable "capacity" {
  type        = number
  description = "The size of the Redis cache to deploy. Valid values depend on the SKU family."
  nullable    = false

  validation {
    condition     = var.capacity >= 0 && var.capacity <= 6
    error_message = "The capacity must be between 0 and 6."
  }
}

variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "Enable the non-SSL port (6379)."
  nullable    = false
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version."
  nullable    = false

  validation {
    condition     = can(regex("^(1.0|1.1|1.2)$", var.minimum_tls_version))
    error_message = "The minimum TLS version must be one of '1.0', '1.1', or '1.2'."
  }
}

variable "public_network_access" {
  type        = string
  default     = "Enabled"
  description = "Whether public network access is allowed. Possible values are Enabled and Disabled."
  nullable    = false

  validation {
    condition     = can(regex("^(Enabled|Disabled)$", var.public_network_access))
    error_message = "The public network access must be either 'Enabled' or 'Disabled'."
  }
}

variable "redis_configuration" {
  type = object({
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
  })
  default     = null
  description = "Redis configuration settings."
}

variable "replicas_per_master" {
  type        = number
  default     = null
  description = "The number of replicas per master (deprecated, use replicas_per_primary)."
}

variable "replicas_per_primary" {
  type        = number
  default     = null
  description = "The number of replicas per primary."
}

variable "shard_count" {
  type        = number
  default     = null
  description = "The number of shards to create on a Premium Cluster Cache."
}

variable "static_ip" {
  type        = string
  default     = null
  description = "The static IP address to assign to the Redis cache."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The subnet ID for the Redis cache (Premium SKU only)."
}

variable "tenant_settings" {
  type        = map(string)
  default     = null
  description = "A mapping of tenant settings to assign to the resource."
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "A list of availability zones where the Redis cache should be located."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Tags to assign to the Redis cache."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = "The timeouts for creating, reading, updating, and deleting the database resource."
}
