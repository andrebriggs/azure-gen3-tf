terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.20.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# To generate passwords.
provider "random" {}

# used as a random slug for each resource name
resource "random_string" "rand" {
  length  = 4
  special = false
  number  = false
  upper   = false
}

locals {
  prefix = format("%s-%s-%s", var.service_name, var.env, random_string.rand.result)
  tags = {
    environment = var.env
    service     = var.service_name
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group
}
