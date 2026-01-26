# Azure Managed Redis instances
# Each instance consists of a cluster and its required default database

locals {
  # Azure Redis Enterprise API version
  redis_enterprise_api_version = "2024-10-01"
}

# Redis Enterprise Cluster
resource "azapi_resource" "managed_redis_cluster" {
  for_each = var.managed_redis_databases

  location  = var.location
  name      = "${var.name}-${each.key}"
  parent_id = var.resource_group_id
  type      = "Microsoft.Cache/redisEnterprise@${local.redis_enterprise_api_version}"
  body = {
    sku = {
      name = each.value.sku_name
    }
    properties = {
      minimumTlsVersion = try(each.value.minimum_tls_version, "1.2")
    }
  }
  response_export_values    = ["properties.hostName"]
  schema_validation_enabled = false
  tags                      = try(each.value.tags, var.tags)

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# Redis Database within the cluster
resource "azapi_resource" "managed_redis_database" {
  for_each = var.managed_redis_databases

  name      = "default"
  parent_id = azapi_resource.managed_redis_cluster[each.key].id
  type      = "Microsoft.Cache/redisEnterprise/databases@${local.redis_enterprise_api_version}"
  body = {
    properties = {
      clientProtocol   = try(each.value.enable_non_ssl_port, false) ? "Plaintext" : "Encrypted"
      evictionPolicy   = try(each.value.eviction_policy, "AllKeysLRU")
      clusteringPolicy = try(each.value.clustering_policy, "EnterpriseCluster")
      modules          = try(each.value.redis_modules, [])
    }
  }
  response_export_values    = ["id"]
  schema_validation_enabled = false

  dynamic "timeouts" {
    for_each = try(each.value.timeouts, null) == null ? [] : [each.value.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azapi_resource.managed_redis_cluster]
}
