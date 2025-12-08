<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.13, < 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.13, < 3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.cluster](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.database](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_non_ssl_port"></a> [enable\_non\_ssl\_port](#input\_enable\_non\_ssl\_port) | Enable non-SSL port (6379). If false, uses encrypted protocol. If true, uses plaintext protocol. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Redis cache will be deployed. | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the Redis Enterprise cluster. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure Managed Redis cache. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource ID of the resource group. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for Azure Managed Redis. Valid values: Balanced\_B0, Balanced\_B1, Balanced\_B3, Balanced\_B5, Memory-Optimized\_M10, Memory-Optimized\_M20, Compute-Optimized\_X5, etc. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to the Redis cache. | `map(string)` | `null` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | The timeouts for creating, reading, updating, and deleting the database resource. | <pre>object({<br/>    create = optional(string)<br/>    delete = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database"></a> [database](#output\_database) | The full Redis Enterprise database resource. |
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | The resource ID of the Redis Enterprise database. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The hostname of the Redis Enterprise database. |
| <a name="output_resource"></a> [resource](#output\_resource) | The full Redis Enterprise cluster resource. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The resource ID of the Redis Enterprise cluster. |
<!-- END_TF_DOCS -->