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
  description = "The SKU name for Azure Managed Redis. Valid values: Balanced_B0, Balanced_B1, Balanced_B3, Balanced_B5, Memory-Optimized_M10, Memory-Optimized_M20, Compute-Optimized_X5, etc."
  nullable    = false
}

# Deprecated - kept for backward compatibility but not used
variable "family" {
  type        = string
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis. Kept for backward compatibility."
}

# Deprecated - kept for backward compatibility but not used
variable "capacity" {
  type        = number
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis. Kept for backward compatibility."
}

variable "redis_configuration" {
  type = object({
    maxmemory_policy                = optional(string, "volatile-lru")
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
  description = "Redis configuration settings. Note: Azure Managed Redis has limited configuration options."
}

# The following variables are kept for backward compatibility but not used in Azure Managed Redis
variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "DEPRECATED: Not used in Azure Managed Redis."
  nullable    = false
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "DEPRECATED: Not used in Azure Managed Redis."
  nullable    = false
}

variable "public_network_access" {
  type        = string
  default     = "Enabled"
  description = "DEPRECATED: Not used in Azure Managed Redis."
  nullable    = false
}

variable "replicas_per_master" {
  type        = number
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "replicas_per_primary" {
  type        = number
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "shard_count" {
  type        = number
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "static_ip" {
  type        = string
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "tenant_settings" {
  type        = map(string)
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
}

variable "zones" {
  type        = list(string)
  default     = null
  description = "DEPRECATED: Not used in Azure Managed Redis."
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
