
# https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html
resource "azurerm_virtual_network" "network" {
  name                = format("%s-vnet", local.prefix)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  # TODO: can be smaller
  address_space = ["10.0.0.0/8"]
  tags          = local.tags
}

##
# This subnet is used to assign IPs on the virtual network for Cluster nodes and pods
# https://www.terraform.io/docs/providers/azurerm/r/subnet.html
resource "azurerm_subnet" "subnet" {
  name                 = "gen3-services"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.1.0.0/16"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ]
}

##
# This subnet is used to assign IPs for private links and avoids consuming IP addresses from the cluster's subnet
# https://www.terraform.io/docs/providers/azurerm/r/subnet.html
resource "azurerm_subnet" "private_link_services" {
  name                 = "plink-services"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.2.1.0/24"]

  # required to enable private link in this subnet
  enforce_private_link_endpoint_network_policies = true

  service_endpoints = [
    "Microsoft.Sql"
  ]
}
