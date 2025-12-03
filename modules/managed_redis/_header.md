# Azure Managed Redis Cache Sub-module

This sub-module creates individual Azure Managed Redis (Azure Cache for Redis) instances using the AzAPI provider.

## Features

- Supports Basic, Standard, and Premium SKUs
- Configurable Redis settings (maxmemory policies, authentication, etc.)
- Network configuration including VNET integration (Premium)
- High availability with replicas (Premium)
- Sharding support (Premium)
- Backup and persistence options (Premium)
- Availability zones support
- TLS version configuration
- Public/private network access control

## Usage

This module is called internally by the parent module and should not typically be used directly:

```terraform
module "managed_redis" {
  source = "./modules/managed_redis"

  name              = "myredis"
  location          = "eastus"
  resource_group_id = azurerm_resource_group.example.id

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  redis_configuration = {
    maxmemory_policy       = "volatile-lru"
    authentication_enabled = true
  }
}
```

