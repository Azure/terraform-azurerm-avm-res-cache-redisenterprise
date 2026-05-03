# Azure Managed Redis Terraform Module

This Terraform module deploys **Azure Managed Redis** (Redis Enterprise) instances on Azure.

## Features

- Deploy Azure Managed Redis (Redis Enterprise) with various SKUs (Balanced, Memory/Compute/Flash Optimized)
- Configurable clustering policies (EnterpriseCluster, OSSCluster, NoEviction)
- Eviction policies (AllKeysLRU, AllKeysRandom, VolatileLRU, VolatileTTL, NoEviction)
- Redis modules support (RediSearch, RedisJSON, RedisBloom, RedisTimeSeries)
- TLS 1.2 support with optional non-SSL port
- Access key authentication disabled by default with opt-in support
- Optional AOF or RDB database persistence
- Optional database geo-replication configuration
- Public network access controls
- Managed identity support (SystemAssigned and UserAssigned)
- Optional customer-managed key (CMK) encryption
- Optional high availability mode and availability zones
- Database access policy assignments for Microsoft Entra principals
- Diagnostic settings for the Redis Enterprise cluster and database
- Optional private endpoints for secure connectivity
- Management locks and RBAC role assignments
- Configurable timeouts for long-running operations

## Usage

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

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.example.id]
  }

  high_availability = "Enabled"
  zones             = ["1", "2", "3"]

  customer_managed_key_encryption = {
    key_encryption_key_url             = "https://kv-example.vault.azure.net/keys/redis-cmk/00000000000000000000000000000000"
    identity_type                      = "UserAssignedIdentity"
    user_assigned_identity_resource_id = azurerm_user_assigned_identity.example.id
  }

  access_policy_assignments = {
    app_identity = {
      object_id          = "00000000-0000-0000-0000-000000000000"
      access_policy_name = "default"
    }
  }
}
```
