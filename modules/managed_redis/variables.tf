variable "location" {
  type        = string
  description = "The Azure region where the Redis cache will be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the Azure Managed Redis cache."

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name))
    error_message = "The name must be between 1 and 63 characters and contain only alphanumeric characters and hyphens."
  }
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

variable "enable_non_ssl_port" {
  type        = bool
  default     = false
  description = "Enable non-SSL port (6379). If false, uses encrypted protocol. If true, uses plaintext protocol."
  nullable    = false
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum TLS version for the Redis Enterprise cluster."
  nullable    = false
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
