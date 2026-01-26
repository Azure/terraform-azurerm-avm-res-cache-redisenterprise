# Azure Managed Redis Module
# Creates a Redis Enterprise cluster with a database

locals {
  # Azure Redis Enterprise API version
  redis_enterprise_api_version = "2024-10-01"
}

# Redis Enterprise Cluster
resource "azapi_resource" "cluster" {
  location  = var.location
  name      = var.name
  parent_id = var.resource_group_id
  type      = "Microsoft.Cache/redisEnterprise@${local.redis_enterprise_api_version}"
  body = {
    sku = {
      name = var.sku_name
    }
    properties = {
      minimumTlsVersion = var.minimum_tls_version
    }
  }
  response_export_values    = ["properties.hostName"]
  schema_validation_enabled = false
  tags                      = var.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# Redis Database within the cluster
resource "azapi_resource" "database" {
  name      = "default"
  parent_id = azapi_resource.cluster.id
  type      = "Microsoft.Cache/redisEnterprise/databases@${local.redis_enterprise_api_version}"
  body = {
    properties = {
      clientProtocol   = var.enable_non_ssl_port ? "Plaintext" : "Encrypted"
      evictionPolicy   = var.eviction_policy
      clusteringPolicy = var.clustering_policy
      modules          = var.redis_modules
    }
  }
  response_export_values    = ["id"]
  schema_validation_enabled = false

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azapi_resource.cluster]
}
