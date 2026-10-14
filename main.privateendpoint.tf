resource "azapi_resource" "this_private_endpoint" {
  for_each = var.private_endpoints

  location = each.value.location != null ? each.value.location : var.location
  name     = each.value.name != null ? each.value.name : "pe-${var.name}"
  parent_id = each.value.resource_group_name != null ? (
    can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", each.value.resource_group_name)) ?
    each.value.resource_group_name :
    "/subscriptions/${provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).subscription_id}/resourceGroups/${each.value.resource_group_name}"
  ) : var.parent_id
  type = "Microsoft.Network/privateEndpoints@2024-03-01"
  body = {
    properties = {
      applicationSecurityGroups = [
        for asg_resource_id in each.value.application_security_group_associations : {
          id = asg_resource_id
        }
      ]
      customNetworkInterfaceName = each.value.network_interface_name != null ? each.value.network_interface_name : ""
      ipConfigurations = [
        for ip_k, ip_v in each.value.ip_configurations : {
          name = ip_v.name
          properties = {
            groupId          = coalesce(each.value.subresource_name, "redisEnterprise")
            memberName       = coalesce(ip_v.member_name, "redisEnterprise")
            privateIPAddress = ip_v.private_ip_address
          }
        }
      ]
      privateLinkServiceConnections = [
        {
          name = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
          properties = {
            privateLinkServiceId = azapi_resource.this.id
            groupIds             = [coalesce(each.value.subresource_name, "redisEnterprise")]
          }
        }
      ]
      subnet = {
        id = each.value.subnet_resource_id
      }
    }
  }
  response_export_values = []
  tags                   = each.value.tags != null ? each.value.tags : var.tags

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

resource "azapi_resource" "this_private_endpoint_private_dns_zone_group" {
  for_each = {
    for k, v in var.private_endpoints : k => v
    if var.private_endpoints_manage_dns_zone_group && length(v.private_dns_zone_resource_ids) > 0
  }

  name      = each.value.private_dns_zone_group_name
  parent_id = azapi_resource.this_private_endpoint[each.key].id
  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-03-01"
  body = {
    properties = {
      privateDnsZoneConfigs = [
        for zone_id in each.value.private_dns_zone_resource_ids : {
          name = replace(split("/", zone_id)[8], ".", "-")
          properties = {
            privateDnsZoneId = zone_id
          }
        }
      ]
    }
  }
  response_export_values = []
}

resource "azapi_update_resource" "this_private_endpoint_asg_association" {
  for_each = local.private_endpoint_application_security_group_associations

  resource_id = azapi_resource.this_private_endpoint[each.value.pe_key].id
  type        = "Microsoft.Network/privateEndpoints@2024-03-01"
  body = {
    properties = {
      applicationSecurityGroups = [
        # Retain existing association addresses, but never overwrite another association.
        for asg_resource_id in var.private_endpoints[each.value.pe_key].application_security_group_associations : {
          id = asg_resource_id
        }
      ]
    }
  }
  response_export_values = []
}

resource "azapi_resource" "private_endpoint_role_assignments" {
  for_each = module.avm_interfaces.role_assignments_private_endpoint_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.this_private_endpoint[each.value.pe_key].id
  type                   = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body                   = each.value.body
  response_export_values = []

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "private_endpoint_locks" {
  for_each = module.avm_interfaces.lock_private_endpoint_azapi

  name                   = coalesce(each.value.name, "lock-${each.value.body.properties.level}")
  parent_id              = azapi_resource.this_private_endpoint[each.value.pe_key].id
  type                   = "Microsoft.Authorization/locks@2020-05-01"
  body                   = each.value.body
  response_export_values = []

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    azapi_resource.this_private_endpoint_private_dns_zone_group,
    azapi_update_resource.this_private_endpoint_asg_association,
    azapi_resource.private_endpoint_role_assignments,
  ]
}
