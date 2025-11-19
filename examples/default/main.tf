terraform {
  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.21"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call for Azure Managed Redis (standalone)
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-cache-redisenterprise/azurerm"
  # version            = "~> 0.1"

  location            = azurerm_resource_group.this.location
  name                = module.naming.redis_cache.name_unique
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id

  # SKU configuration (required for Redis Enterprise infrastructure)
  sku = {
    name     = "Balanced_B0" # Minimum SKU for testing
    capacity = null          # Only used with Enterprise and EnterpriseFlash SKUs
  }

  # High availability configuration
  enable_high_availability = true

  # Azure Managed Redis databases configuration
  managed_redis_databases = {
    default = {
      sku_name = "Balanced_B1" # Azure Managed Redis SKU: Balanced tier

      # Redis configuration
      redis_configuration = {
        maxmemory_policy = "volatile-lru"
      }
    }
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
}
