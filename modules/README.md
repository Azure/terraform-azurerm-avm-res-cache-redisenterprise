# Sub-modules

This directory contains sub-modules used by the main module.

## managed_redis

The `managed_redis` sub-module is responsible for creating individual Azure Managed Redis cache instances using the AzAPI provider. This sub-module handles:

- Redis cache resource creation
- SKU configuration (Basic, Standard, Premium)
- Redis configuration settings
- Network configuration
- High availability settings (Premium)
- Backup and persistence configuration (Premium)

README.md files are automatically generated for each sub-module using `terraform-docs`.

