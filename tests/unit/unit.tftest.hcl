mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Cache/redisEnterprise/redisenterprise"
      output = {
        properties = {
          hostName     = "redisenterprise.eastus.redisenterprise.cache.azure.net"
          redisVersion = "7.2"
        }
      }
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

variables {
  location         = "eastus"
  name             = "redisenterprise"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  sku_name         = "Balanced_B0"
  enable_telemetry = false
}

run "default_database_disables_access_keys" {
  command = apply

  assert {
    condition     = azapi_resource.database.body.properties.accessKeysAuthentication == "Disabled"
    error_message = "Access key authentication should be disabled by default."
  }

  assert {
    condition     = try(azapi_resource.database.body.properties.persistence, null) == null
    error_message = "Persistence should be omitted unless configured."
  }
}

run "database_auth_persistence_and_principals_can_be_configured" {
  command = apply

  variables {
    access_keys_authentication_enabled = true
    access_policy_assignments = {
      appidentity = {
        name               = "appidentity"
        object_id          = "11111111-1111-1111-1111-111111111111"
        access_policy_name = "default"
      }
      generatedname = {
        object_id = "22222222-2222-2222-2222-222222222222"
      }
    }
    database_diagnostic_settings = {
      workspace = {
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
      }
    }
    diagnostic_settings = {
      workspace = {
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.OperationalInsights/workspaces/law-test"
      }
    }
    geo_replication = {
      group_nickname = "activeactive"
      linked_databases = [
        {
          id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Cache/redisEnterprise/redisenterprise-secondary/databases/default"
        }
      ]
    }
    clustering_policy = "NoCluster"
    persistence = {
      rdb_enabled   = true
      rdb_frequency = "6h"
    }
  }

  assert {
    condition     = azapi_resource.database.body.properties.accessKeysAuthentication == "Enabled"
    error_message = "Access key authentication should be enabled when opted in."
  }

  assert {
    condition     = azapi_resource.database.body.properties.persistence.rdbEnabled == true && azapi_resource.database.body.properties.persistence.rdbFrequency == "6h"
    error_message = "RDB persistence should be passed to the database resource."
  }

  assert {
    condition     = azapi_resource.database.body.properties.geoReplication.groupNickname == "activeactive" && length(azapi_resource.database.body.properties.geoReplication.linkedDatabases) == 1
    error_message = "Geo-replication settings should be passed to the database resource."
  }

  assert {
    condition     = azapi_resource.database.body.properties.clusteringPolicy == "NoCluster"
    error_message = "NoCluster should be accepted as a clustering policy."
  }

  assert {
    condition     = azapi_resource.access_policy_assignment["appidentity"].body.properties.user.objectId == "11111111-1111-1111-1111-111111111111"
    error_message = "Access policy assignments should pass the supplied Microsoft Entra object ID to the API."
  }

  assert {
    condition     = azapi_resource.access_policy_assignment["appidentity"].name == "appidentity"
    error_message = "Access policy assignments should use the configured assignment name when provided."
  }

  assert {
    condition     = azapi_resource.access_policy_assignment["generatedname"].body.properties.user.objectId == "22222222-2222-2222-2222-222222222222"
    error_message = "Access policy assignments should support generated names for supplied object IDs."
  }

  assert {
    condition     = azapi_resource.access_policy_assignment["generatedname"].name == replace(uuidv5("dns", "22222222-2222-2222-2222-222222222222"), "-", "")
    error_message = "Access policy assignments should generate stable assignment names from the object ID."
  }

  assert {
    condition     = azapi_resource.diagnostic_settings["workspace"].parent_id == azapi_resource.this.id && azapi_resource.diagnostic_settings["workspace"].body.properties.metrics[0].category == "AllMetrics"
    error_message = "Cluster diagnostic settings should target the cluster and enable metrics by default."
  }

  assert {
    condition     = azapi_resource.database_diagnostic_settings["workspace"].parent_id == azapi_resource.database.id && azapi_resource.database_diagnostic_settings["workspace"].body.properties.logs[0].category == "ConnectionEvents"
    error_message = "Database diagnostic settings should target the database and enable connection logs by default."
  }
}

run "persistence_rejects_multiple_modes" {
  command = plan

  variables {
    persistence = {
      aof_enabled = true
      rdb_enabled = true
    }
  }

  expect_failures = [
    var.persistence
  ]
}

run "persistence_rejects_invalid_frequency" {
  command = plan

  variables {
    persistence = {
      rdb_enabled   = true
      rdb_frequency = "24h"
    }
  }

  expect_failures = [
    var.persistence
  ]
}

run "clustering_policy_rejects_no_eviction" {
  command = plan

  variables {
    clustering_policy = "NoEviction"
  }

  expect_failures = [
    var.clustering_policy
  ]
}
