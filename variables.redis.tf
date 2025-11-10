# TODO This can't be false if a Balanced SKU is used - suspect this is also true for other redis enterprise SKUs.
variable "enable_high_availability" {
  description = "Indicates whether high availability is enabled."
  type        = bool
  default     = true
}

variable "sku" {
  description = <<DESCRIPTION
Optional Redis Enterprise cluster SKU configuration. Only required if deploying Redis Enterprise infrastructure.

- `capacity` - This property is only used with Enterprise and EnterpriseFlash SKUs. Determines the size of the cluster. Valid values are (2, 4, 6, ...) for Enterprise SKUs and (3, 9, 15, ...) for EnterpriseFlash SKUs.
- `name` - The level of Redis Enterprise cluster to deploy. Possible values: ('Balanced_B5', 'MemoryOptimized_M10', 'ComputeOptimized_X5', etc.). For more information on SKUs see the latest pricing documentation. Note that additional SKUs may become supported in the future.

DESCRIPTION

  type = object({
    capacity = optional(number)
    name     = string
  })
  default = null
  validation {
    condition = var.sku == null || contains([
      "Balanced_B0", "Balanced_B1", "Balanced_B10", "Balanced_B100", "Balanced_B1000", "Balanced_B150", "Balanced_B20", "Balanced_B250", "Balanced_B3", "Balanced_B350", "Balanced_B5", "Balanced_B50", "Balanced_B500", "Balanced_B700",
      "ComputeOptimized_X10", "ComputeOptimized_X100", "ComputeOptimized_X150", "ComputeOptimized_X20", "ComputeOptimized_X250", "ComputeOptimized_X3", "ComputeOptimized_X350", "ComputeOptimized_X5", "ComputeOptimized_X50", "ComputeOptimized_X500", "ComputeOptimized_X700",
      "EnterpriseFlash_F1500", "EnterpriseFlash_F300", "EnterpriseFlash_F700",
      "Enterprise_E1", "Enterprise_E10", "Enterprise_E100", "Enterprise_E20", "Enterprise_E200", "Enterprise_E400", "Enterprise_E5", "Enterprise_E50",
      "FlashOptimized_A1000", "FlashOptimized_A1500", "FlashOptimized_A2000", "FlashOptimized_A250", "FlashOptimized_A4500", "FlashOptimized_A500", "FlashOptimized_A700",
      "MemoryOptimized_M10", "MemoryOptimized_M100", "MemoryOptimized_M1000", "MemoryOptimized_M150", "MemoryOptimized_M1500", "MemoryOptimized_M20", "MemoryOptimized_M2000", "MemoryOptimized_M250", "MemoryOptimized_M350", "MemoryOptimized_M50", "MemoryOptimized_M500", "MemoryOptimized_M700"
    ], var.sku.name)
    error_message = "Invalid SKU name. Please provide a valid SKU name."
  }
}

# TODO This must be all zones if a Balanced SKU is used - suspect this is also true for other redis enterprise SKUs.
# variable "zones" {
#   description = "The availability zones for the Redis Enterprise cache."
#   type        = list(string)
#   default     = ["1", "2", "3"]
# }
