# Azure Managed Redis Module
# Creates a Redis Enterprise cluster with a database

locals {
  # Azure Redis Enterprise API version
  redis_enterprise_api_version = "2024-10-01"

}

# Redis Enterprise Cluster
resource "azapi_resource" "cluster" {
  type      = "Microsoft.Cache/redisEnterprise@${local.redis_enterprise_api_version}"
  name      = var.name
  location  = var.location
  parent_id = var.resource_group_id

  body = {
    sku = {
      name = var.sku_name
    }
    properties = {
      minimumTlsVersion = var.minimum_tls_version
    }
  }

  tags                      = var.tags
  response_export_values    = ["*"]
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
}

# Redis Database within the cluster
resource "azapi_resource" "database" {
  type      = "Microsoft.Cache/redisEnterprise/databases@${local.redis_enterprise_api_version}"
  name      = "default"
  parent_id = azapi_resource.cluster.id

  body = {
    properties = {
      clientProtocol   = var.enable_non_ssl_port ? "Plaintext" : "Encrypted"
      evictionPolicy   = "AllKeysLRU"
      clusteringPolicy = "EnterpriseCluster"
      modules          = []
    }
  }

  response_export_values    = ["*"]
  schema_validation_enabled = false

  depends_on = [azapi_resource.cluster]

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
