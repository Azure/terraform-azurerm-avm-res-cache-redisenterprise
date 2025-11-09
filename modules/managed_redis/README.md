<!-- BEGIN_TF_DOCS -->
# Azure Managed Redis Database

This module is used to create a database for Azure Managed Redis Cache.

## Usage

```terraform
# TODO
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (>= 1.13, < 3)

## Resources

The following resources are used by this module:

- [azapi_resource.database](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Redis Enterprise database.

Type: `string`

### <a name="input_redis_cache"></a> [redis\_cache](#input\_redis\_cache)

Description: The resource ID of the Redis Enterprise cache.

Type:

```hcl
object({
    resource_id = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_access_keys_authentication"></a> [access\_keys\_authentication](#input\_access\_keys\_authentication)

Description: Indicates whether access keys authentication is enabled.

Type: `bool`

Default: `false`

### <a name="input_client_protocol"></a> [client\_protocol](#input\_client\_protocol)

Description: The client protocol to use.

Type: `string`

Default: `"Encrypted"`

### <a name="input_clustering_policy"></a> [clustering\_policy](#input\_clustering\_policy)

Description: The clustering policy for the database.

Type: `string`

Default: `"OSSCluster"`

### <a name="input_defer_upgrade"></a> [defer\_upgrade](#input\_defer\_upgrade)

Description: Indicates whether to defer upgrades.

Type: `bool`

Default: `false`

### <a name="input_eviction_policy"></a> [eviction\_policy](#input\_eviction\_policy)

Description: The eviction policy for the database.

Type: `string`

Default: `"VolatileLRU"`

### <a name="input_geo_replication"></a> [geo\_replication](#input\_geo\_replication)

Description: Configuration for geo-replication.

Type:

```hcl
object({
    group_nickname = string
    linkedDatabases = list(object({
      id = string
    }))
  })
```

Default:

```json
{
  "group_nickname": "",
  "linkedDatabases": []
}
```

### <a name="input_modules"></a> [modules](#input\_modules)

Description: List of modules to be enabled in the database.

Type:

```hcl
list(object({
    args = string
    name = string
  }))
```

Default: `[]`

### <a name="input_persistence"></a> [persistence](#input\_persistence)

Description: Persistence configuration for the database.

Type:

```hcl
object({
    aof_enabled   = bool
    aof_frequency = string
    rdb_enabled   = bool
    rdb_frequency = string
  })
```

Default: `null`

### <a name="input_port"></a> [port](#input\_port)

Description: The port number for the database.  Defaults to an available port.

Type: `number`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: The timeouts for creating, reading, updating, and deleting the database resource.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The resource ID of the database resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->