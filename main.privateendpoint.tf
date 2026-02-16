resource "azapi_resource" "this_private_endpoint" {
  for_each = var.private_endpoints

  location = each.value.location != null ? each.value.location : var.location
  name     = each.value.name != null ? each.value.name : "pe-${var.name}"
  parent_id = each.value.resource_group_name != null ? (
    format("%s/resourceGroups/%s",
      join("/", slice(split("/", var.parent_id), 0, 5)),
      each.value.resource_group_name
    )
  ) : var.parent_id
  type = "Microsoft.Network/privateEndpoints@2023-11-01"
  body = {
    properties = {
      customNetworkInterfaceName = each.value.network_interface_name
      ipConfigurations = [
        for ip_k, ip_v in each.value.ip_configurations : {
          name = ip_v.name
          properties = {
            groupId          = "redisCache"
            memberName       = "redisCache"
            privateIPAddress = ip_v.private_ip_address
          }
        }
      ]
      privateLinkServiceConnections = [
        {
          name = each.value.private_service_connection_name != null ? each.value.private_service_connection_name : "pse-${var.name}"
          properties = {
            privateLinkServiceId = azapi_resource.this.id
            groupIds             = ["redisCache"]
          }
        }
      ]
      subnet = {
        id = each.value.subnet_resource_id
      }
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  tags           = each.value.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
    }
  }
}

# Private DNS Zone Group - only created when managing DNS zones
resource "azapi_resource" "this_private_endpoint_private_dns_zone_group" {
  for_each = {
    for k, v in var.private_endpoints : k => v
    if var.private_endpoints_manage_dns_zone_group && length(v.private_dns_zone_resource_ids) > 0
  }

  name      = each.value.private_dns_zone_group_name
  parent_id = azapi_resource.this_private_endpoint[each.key].id
  type      = "Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01"
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
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

# Application Security Group Associations
resource "azapi_update_resource" "this_private_endpoint_asg_association" {
  for_each = local.private_endpoint_application_security_group_associations

  resource_id = azapi_resource.this_private_endpoint[each.value.pe_key].id
  type        = "Microsoft.Network/privateEndpoints@2023-11-01"
  body = {
    properties = {
      applicationSecurityGroups = [
        {
          id = each.value.asg_resource_id
        }
      ]
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}
