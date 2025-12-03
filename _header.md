# Azure Managed Redis Terraform Module

This Terraform module deploys **Azure Managed Redis** (standalone cache service) instances on Azure.

## Features

- Deploy Azure Managed Redis with Basic, Standard, or Premium SKUs
- Support for high availability (Premium SKU)
- Configurable Redis settings (maxmemory policies, authentication, etc.)
- Optional private endpoints
- Management locks and RBAC role assignments
- Network isolation with VNET integration (Premium SKU)
- Backup and persistence options (Premium SKU)
- Availability zones support

## Usage

```hcl
module "redis" {
  source  = "Azure/avm-res-cache-redisenterprise/azurerm"
  version = "~> 0.1"

  location            = "eastus"
  name                = "myredis"
  resource_group_name = azurerm_resource_group.example.name
  resource_group_id   = azurerm_resource_group.example.id

  managed_redis_databases = {
    default = {
      sku_name = "Standard"
      family   = "C"
      capacity = 1

      redis_configuration = {
        maxmemory_policy       = "volatile-lru"
        authentication_enabled = true
      }
    }
  }
}
```

