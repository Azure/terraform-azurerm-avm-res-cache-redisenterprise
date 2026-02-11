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
  version = "0.9.2"
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

# This is the module call for Azure Managed Redis
module "test" {
  source = "../../"

  location  = azurerm_resource_group.this.location
  name      = module.naming.redis_cache.name_unique
  parent_id = azurerm_resource_group.this.id
  # Redis Enterprise cluster configuration
  sku_name            = "Balanced_B0" # Azure Managed Redis SKU (lowest cost)
  clustering_policy   = "EnterpriseCluster"
  enable_non_ssl_port = false
  enable_telemetry    = var.enable_telemetry # see variables.tf
  eviction_policy     = "AllKeysLRU"
  minimum_tls_version = "1.2"
  # Optional: Tags
  tags = {
    environment = "demo"
    managed_by  = "terraform"
  }
}
