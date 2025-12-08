terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
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
  version = "0.1.0"
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
  version = "0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# This is the module call for Azure Managed Redis - Premium SKU example
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-cache-redisenterprise/azurerm"
  # version            = "~> 0.1"

  location            = azurerm_resource_group.this.location
  name                = module.naming.redis_cache.name_unique
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id   = azurerm_resource_group.this.id

  # Azure Managed Redis databases configuration
  managed_redis_databases = {
    premium = {
      sku_name            = "Balanced_B1" # Azure Managed Redis SKU: Balanced tier
      minimum_tls_version = "1.2"
      enable_non_ssl_port = false
    }
  }

  # Optional: Tags
  tags = {
    environment = "testing"
    managed_by  = "terraform"
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
}
