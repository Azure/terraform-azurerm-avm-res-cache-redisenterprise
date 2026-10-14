# Azure Managed Redis Terraform Module

This Terraform module deploys **Azure Managed Redis** (Redis Enterprise) instances on Azure.

## Features

- Deploy Azure Managed Redis (Redis Enterprise) with various SKUs (Balanced, Memory/Compute/Flash Optimized)
- Configurable clustering policies (EnterpriseCluster, OSSCluster, NoEviction)
- Eviction policies (AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileTTL, NoEviction)
- Redis modules support (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries)
- TLS 1.2 support with optional non-SSL port
- Public network access controls
- Optional private endpoints for secure connectivity
- Management locks and RBAC role assignments
- Configurable timeouts for long-running operations

## Usage

Private endpoints retain their existing Terraform addresses and generated names.
Endpoint tags inherit the module tags unless an endpoint supplies its own map (including an empty map).
Endpoint locks and role assignments are now applied; review these settings before upgrading.
An omitted endpoint lock inherits the cluster lock; use `lock = { kind = "None" }` to opt out.
`resource_group_name` accepts a resource group ID
or, for compatibility, a resource group name in the cluster's subscription.
The default private-link group and IP configuration member remain `redisEnterprise`.

```hcl
module "redis" {
  source  = "Azure/avm-res-cache-redisenterprise/azurerm"
  version = "~> 0.1"

  location            = "eastus"
  name                = "myredis"
  parent_id           = azurerm_resource_group.example.id

  sku_name            = "Balanced_B0"
  minimum_tls_version = "1.2"
  enable_non_ssl_port = false
  clustering_policy   = "EnterpriseCluster"
  eviction_policy     = "AllKeysLRU"
}
```
