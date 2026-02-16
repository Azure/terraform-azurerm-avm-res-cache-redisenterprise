# Azure Managed Redis Enterprise
# Creates a single Redis Enterprise cluster with its default database

# Redis Enterprise Cluster
resource "azapi_resource" "this" {
  location  = var.location
  name      = var.name
  parent_id = var.parent_id
  type      = "Microsoft.Cache/redisEnterprise@2025-07-01"
  body = {
    sku = {
      name = var.sku_name
    }
    properties = {
      minimumTlsVersion   = var.minimum_tls_version
      publicNetworkAccess = var.public_network_access
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
    for_each = var.timeouts != null ? [var.timeouts] : []

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
  type      = "Microsoft.Cache/redisEnterprise/databases@2025-07-01"
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
  schema_validation_enabled = false
  update_headers            = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
