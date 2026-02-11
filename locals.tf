locals {
  # Private endpoint application security group associations.
  # We merge the nested maps from private endpoints and application security group associations into a single map.
  private_endpoint_application_security_group_associations = { for assoc in flatten([
    for pe_k, pe_v in var.private_endpoints : [
      for asg_k, asg_v in pe_v.application_security_group_associations : {
        asg_key         = asg_k
        pe_key          = pe_k
        asg_resource_id = asg_v
      }
    ]
  ]) : "${assoc.pe_key}-${assoc.asg_key}" => assoc }
  # Extract resource group name from parent_id for use in resources that require it
  resource_group_name                = split("/", var.parent_id)[4]
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
