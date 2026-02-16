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
      sku_name            = "Balanced_B0"  # Azure Managed Redis SKU
      minimum_tls_version = "1.2"
      enable_non_ssl_port = false
      clustering_policy   = "EnterpriseCluster"
      eviction_policy     = "AllKeysLRU"
    }
  }
}
```

