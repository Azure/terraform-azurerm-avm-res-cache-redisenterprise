mock_provider "azapi" {
  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [{
          role_name = "Reader"
          id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
        }]
      }
    }
  }
}

mock_provider "modtm" {}

mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-4111-8111-111111111111"
    }
  }
}

override_resource {
  target = azapi_resource.this
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/redis/providers/Microsoft.Cache/redisEnterprise/example"
    output = {
      properties = {
        hostName     = "example.redis.azure.net"
        redisVersion = "7.4"
      }
    }
  }
}

override_resource {
  target = azapi_resource.this_private_endpoint
  values = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/redis/providers/Microsoft.Network/privateEndpoints/example"
  }
}

variables {
  name             = "example"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/redis"
  sku_name         = "Balanced_B0"
  enable_telemetry = false
  tags             = { environment = "test" }
}

run "defaults_create_no_endpoint_resources" {
  command = apply

  assert {
    condition = (
      length(azapi_resource.this_private_endpoint) == 0 &&
      length(azapi_resource.this_private_endpoint_private_dns_zone_group) == 0 &&
      length(azapi_update_resource.this_private_endpoint_asg_association) == 0 &&
      length(azapi_resource.private_endpoint_role_assignments) == 0 &&
      length(azapi_resource.private_endpoint_locks) == 0 &&
      output.resource_id == azapi_resource.this.id
    )
    error_message = "Empty private endpoints must preserve the default resource graph."
  }
}

run "endpoint_defaults_preserve_names_group_member_and_tags" {
  command = apply

  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        ip_configurations  = { static = { name = "static", private_ip_address = "10.0.1.5" } }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.this_private_endpoint["primary"].name == "pe-example" &&
      azapi_resource.this_private_endpoint["primary"].parent_id == var.parent_id &&
      azapi_resource.this_private_endpoint["primary"].location == var.location &&
      azapi_resource.this_private_endpoint["primary"].tags == var.tags &&
      azapi_resource.this_private_endpoint["primary"].body.properties.customNetworkInterfaceName == "" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].name == "pse-example" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["redisEnterprise"] &&
      azapi_resource.this_private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].properties.privateLinkServiceId == output.resource_id &&
      azapi_resource.this_private_endpoint["primary"].body.properties.ipConfigurations[0].properties.memberName == "redisEnterprise" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.ipConfigurations[0].properties.privateIPAddress == "10.0.1.5"
    )
    error_message = "Existing endpoint defaults must remain stable and inherit module tags."
  }
}

run "explicit_endpoint_fields_dns_lock_and_named_role_are_applied" {
  command = apply

  variables {
    timeouts = { create = "20m", read = "10m", update = "30m", delete = "15m" }
    private_endpoints = {
      primary = {
        name                            = "custom-endpoint"
        subnet_resource_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        location                        = "westus2"
        network_interface_name          = "custom-nic"
        private_service_connection_name = "custom-connection"
        subresource_name                = "redisEnterpriseCache"
        tags                            = { endpoint = "custom" }
        private_dns_zone_group_name     = "redis-dns"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns/providers/Microsoft.Network/privateDnsZones/privatelink.redisenterprise.cache.azure.net",
          "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns/providers/Microsoft.Network/privateDnsZones/custom.example",
        ]
        ip_configurations = {
          static = { name = "static", private_ip_address = "10.0.1.5", member_name = "redisEnterpriseCache" }
        }
        lock = { kind = "CanNotDelete", name = "endpoint-lock", notes = "Protect endpoint" }
        role_assignments = {
          reader = {
            name                                   = "22222222-2222-4222-8222-222222222222"
            role_definition_id_or_name             = "Reader"
            principal_id                           = "33333333-3333-4333-8333-333333333333"
            principal_type                         = "ServicePrincipal"
            skip_service_principal_aad_check       = true
            description                            = "Endpoint reader"
            condition                              = "true"
            condition_version                      = "2.0"
            delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.this_private_endpoint["primary"].name == "custom-endpoint" &&
      azapi_resource.this_private_endpoint["primary"].location == "westus2" &&
      azapi_resource.this_private_endpoint["primary"].tags == tomap({ endpoint = "custom" }) &&
      azapi_resource.this_private_endpoint["primary"].body.properties.customNetworkInterfaceName == "custom-nic" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].name == "custom-connection" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.privateLinkServiceConnections[0].properties.groupIds == ["redisEnterpriseCache"] &&
      azapi_resource.this_private_endpoint["primary"].body.properties.ipConfigurations[0].properties.groupId == "redisEnterpriseCache" &&
      azapi_resource.this_private_endpoint["primary"].body.properties.ipConfigurations[0].properties.memberName == "redisEnterpriseCache" &&
      azapi_resource.this_private_endpoint["primary"].timeouts.update == "30m" &&
      output.private_endpoints["primary"].id == azapi_resource.this_private_endpoint["primary"].id
    )
    error_message = "Explicit endpoint fields and the existing output must be wired."
  }

  assert {
    condition = (
      azapi_resource.this_private_endpoint_private_dns_zone_group["primary"].name == "redis-dns" &&
      azapi_resource.this_private_endpoint_private_dns_zone_group["primary"].parent_id == azapi_resource.this_private_endpoint["primary"].id &&
      length(azapi_resource.this_private_endpoint_private_dns_zone_group["primary"].body.properties.privateDnsZoneConfigs) == 2 &&
      azapi_resource.this_private_endpoint_private_dns_zone_group["primary"].body.properties.privateDnsZoneConfigs[0].name != azapi_resource.this_private_endpoint_private_dns_zone_group["primary"].body.properties.privateDnsZoneConfigs[1].name &&
      azapi_resource.private_endpoint_locks["primary"].name == "endpoint-lock" &&
      azapi_resource.private_endpoint_locks["primary"].parent_id == azapi_resource.this_private_endpoint["primary"].id &&
      azapi_resource.private_endpoint_locks["primary"].body.properties.level == "CanNotDelete" &&
      azapi_resource.private_endpoint_locks["primary"].body.properties.notes == "Protect endpoint"
    )
    error_message = "DNS zones and endpoint-specific lock fields must be applied at the endpoint scope."
  }

  assert {
    condition = (
      azapi_resource.private_endpoint_role_assignments["primary-reader"].name == "22222222-2222-4222-8222-222222222222" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].parent_id == azapi_resource.this_private_endpoint["primary"].id &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.principalId == "33333333-3333-4333-8333-333333333333" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.principalType == "ServicePrincipal" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.description == "Endpoint reader" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.condition == "true" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.conditionVersion == "2.0" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.delegatedManagedIdentityResourceId == var.private_endpoints["primary"].role_assignments["reader"].delegated_managed_identity_resource_id
    )
    error_message = "The complete endpoint role assignment must be applied, including role-name resolution."
  }
}

run "alternate_group_name_and_multiple_security_groups" {
  command = apply

  variables {
    private_endpoints = {
      primary = {
        resource_group_name = "network"
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        application_security_group_associations = {
          first  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/applicationSecurityGroups/first"
          second = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/applicationSecurityGroups/second"
        }
        role_assignments = {
          reader = {
            role_definition_id_or_name = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "33333333-3333-4333-8333-333333333333"
          }
        }
      }
    }
  }

  assert {
    condition = (
      azapi_resource.this_private_endpoint["primary"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network" &&
      length(azapi_resource.this_private_endpoint["primary"].body.properties.applicationSecurityGroups) == 2 &&
      length(azapi_update_resource.this_private_endpoint_asg_association) == 2 &&
      azapi_update_resource.this_private_endpoint_asg_association["primary-first"].body == azapi_update_resource.this_private_endpoint_asg_association["primary-second"].body &&
      azapi_update_resource.this_private_endpoint_asg_association["primary-first"].body.properties.applicationSecurityGroups == azapi_resource.this_private_endpoint["primary"].body.properties.applicationSecurityGroups &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].name == "11111111-1111-4111-8111-111111111111"
    )
    error_message = "Resource-group names, GUID roles and all ASGs must work without replacing existing association addresses."
  }
}

run "group_id_empty_tags_and_inherited_lock_with_external_dns" {
  command = apply

  variables {
    lock                                    = { kind = "CanNotDelete", name = "inherited-lock" }
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      primary = {
        resource_group_name           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network"
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        tags                          = {}
        private_dns_zone_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns/providers/Microsoft.Network/privateDnsZones/custom.example"]
      }
    }
  }

  assert {
    condition = (
      azapi_resource.this_private_endpoint["primary"].parent_id == var.private_endpoints["primary"].resource_group_name &&
      length(azapi_resource.this_private_endpoint["primary"].tags) == 0 &&
      length(azapi_resource.this_private_endpoint_private_dns_zone_group) == 0 &&
      azapi_resource.private_endpoint_locks["primary"].name == "inherited-lock" &&
      azapi_resource.private_endpoint_locks["primary"].body.properties.level == "CanNotDelete" &&
      length(azapi_resource.this_private_endpoint["primary"].body.properties.applicationSecurityGroups) == 0
    )
    error_message = "Explicit empty tags, resource-group IDs, inherited locks and externally managed DNS must be respected."
  }
}

run "empty_dns_zones_do_not_create_zone_group" {
  command = apply

  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
      }
    }
  }

  assert {
    condition     = length(azapi_resource.this_private_endpoint_private_dns_zone_group) == 0 && length(azapi_resource.private_endpoint_locks) == 0
    error_message = "No DNS zones or locks must be created when they are not configured."
  }
}

run "endpoint_lock_override_opt_out_and_full_role_id" {
  command = apply

  variables {
    lock = { kind = "CanNotDelete" }
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        lock               = { kind = "ReadOnly" }
        role_assignments = {
          reader = {
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "33333333-3333-4333-8333-333333333333"
          }
        }
      }
      unlocked = {
        name               = "unlocked"
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        lock               = { kind = "None" }
      }
    }
  }

  assert {
    condition = (
      length(azapi_resource.private_endpoint_locks) == 1 &&
      azapi_resource.private_endpoint_locks["primary"].name == "lock-ReadOnly" &&
      azapi_resource.private_endpoint_locks["primary"].body.properties.level == "ReadOnly" &&
      azapi_resource.private_endpoint_role_assignments["primary-reader"].body.properties.roleDefinitionId == var.private_endpoints["primary"].role_assignments["reader"].role_definition_id_or_name
    )
    error_message = "Endpoint lock overrides and opt-out must work, and fully qualified role IDs must remain unchanged."
  }
}

run "reject_invalid_subnet" {
  command = plan
  variables {
    private_endpoints = { primary = { subnet_resource_id = "not-a-subnet" } }
  }
  expect_failures = [var.private_endpoints]
}

run "reject_invalid_dns_zone" {
  command = plan
  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        private_dns_zone_resource_ids = ["not-a-zone"]
      }
    }
  }
  expect_failures = [var.private_endpoints]
}

run "reject_invalid_application_security_group" {
  command = plan
  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        application_security_group_associations = { invalid = "not-an-asg" }
      }
    }
  }
  expect_failures = [var.private_endpoints]
}

run "reject_invalid_delegated_identity" {
  command = plan
  variables {
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vnet/subnets/redis"
        role_assignments = {
          reader = {
            role_definition_id_or_name             = "Reader"
            principal_id                           = "33333333-3333-4333-8333-333333333333"
            delegated_managed_identity_resource_id = "not-an-identity"
          }
        }
      }
    }
  }
  expect_failures = [var.private_endpoints]
}
