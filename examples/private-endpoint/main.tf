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

# Virtual network for private endpoint
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for private endpoint
resource "azurerm_subnet" "this" {
  address_prefixes     = ["10.0.1.0/24"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

# Private DNS zone for Redis Enterprise
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.redisenterprise.cache.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

# Link private DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "${azurerm_virtual_network.this.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

# This is the module call for Azure Managed Redis with private endpoint
module "test" {
  source = "../../"

  location  = azurerm_resource_group.this.location
  name      = module.naming.redis_cache.name_unique
  parent_id = azurerm_resource_group.this.id
  # Redis Enterprise cluster configuration
  sku_name            = "Balanced_B0"
  clustering_policy   = "EnterpriseCluster"
  enable_non_ssl_port = false
  enable_telemetry    = var.enable_telemetry # see variables.tf
  eviction_policy     = "AllKeysLRU"
  minimum_tls_version = "1.2"
  # Private endpoint configuration
  private_endpoints = {
    primary = {
      subnet_resource_id            = azurerm_subnet.this.id
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      tags = {
        environment = "demo"
      }
    }
  }
  public_network_access = "Disabled"
  # Optional: Tags
  tags = {
    environment = "demo"
    managed_by  = "terraform"
  }
}
