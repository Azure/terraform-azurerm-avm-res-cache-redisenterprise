# Azure Managed Redis Enterprise
# Creates a single Redis Enterprise cluster with its default database

locals {
  # Azure Redis Enterprise API version
  redis_enterprise_api_version = "2024-10-01"
}

# Redis Enterprise Cluster
resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Cache/redisEnterprise@${local.redis_enterprise_api_version}"
  body = {
    sku = {
      name = var.sku_name
    }
    properties = {
      minimumTlsVersion = var.minimum_tls_version
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["properties.hostName", "properties.redisVersion"]
  schema_validation_enabled = false
  tags                      = var.tags
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.redis_configuration != null ? [var.redis_configuration] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# Redis Database within the cluster
# Note: Each Redis Enterprise cluster supports exactly one database named "default"
resource "azapi_resource" "database" {
  name      = "default"
  parent_id = azapi_resource.this.id
  type      = "Microsoft.Cache/redisEnterprise/databases@${local.redis_enterprise_api_version}"
  body = {
    properties = {
      clientProtocol   = var.enable_non_ssl_port ? "Plaintext" : "Encrypted"
      evictionPolicy   = var.eviction_policy
      clusteringPolicy = var.clustering_policy
      modules          = var.redis_modules
    }
  }
  create_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers              = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values    = ["properties.provisioningState"]
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.redis_configuration != null ? [var.redis_configuration] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }

  depends_on = [azapi_resource.this]
}
