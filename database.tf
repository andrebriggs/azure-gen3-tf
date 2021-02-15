# https://www.terraform.io/docs/providers/random/r/password.html
resource "random_password" "db_passwd" {
  length  = 64
  special = false
}

# https://www.terraform.io/docs/providers/azurerm/r/postgresql_server.html
resource "azurerm_postgresql_server" "dbserver" {
  name                = format("%s-dbsvr", local.prefix)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  sku_name = var.psql_sku
  version  = 11

  storage_mb                   = 25600 # 25 GB
  backup_retention_days        = 20
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  administrator_login              = "psqladmin"
  administrator_login_password     = random_password.db_passwd.result
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  public_network_access_enabled    = false

  tags = local.tags
}

# Note: there is a bug in the AzureRM Terraform provider that prevents the
# `ssl_minimal_tls_version_enforced` field of `azurerm_postgresql_server` from
# applying in certain scenarios. Once this bug is fixed, the below block can
# be deleted.
#
# More information:
#   https://github.com/terraform-providers/terraform-provider-azurerm/issues/7397
resource "null_resource" "set_psql_tls" {

  provisioner "local-exec" {
    command = "az postgres server update --resource-group ${data.azurerm_resource_group.rg.name} --name ${azurerm_postgresql_server.dbserver.name} --minimal-tls-version TLS1_2"
  }

  triggers = {
    resource_group = data.azurerm_resource_group.rg.name
    db_server_name = azurerm_postgresql_server.dbserver.name
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/postgresql_database.html
resource "azurerm_postgresql_database" "db" {
  name                = "main"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.dbserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# https://www.terraform.io/docs/providers/azurerm/r/postgresql_virtual_network_rule.html
# resource "azurerm_postgresql_virtual_network_rule" "rule" {
#   name                = "postgresql-vnet-rule"
#   resource_group_name = data.azurerm_resource_group.rg.name
#   server_name         = azurerm_postgresql_server.dbserver.name
#   subnet_id           = azurerm_subnet.subnet.id
# }

# https://www.terraform.io/docs/providers/azurerm/r/postgresql_firewall_rule.html
resource "azurerm_postgresql_firewall_rule" "ip_whitelist" {
  count               = length(var.ip_whitelist)
  name                = format("ip-rule-%d", count.index)
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.dbserver.name
  start_ip_address    = var.ip_whitelist[count.index]
  end_ip_address      = var.ip_whitelist[count.index]
}

# # https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html
# resource "azurerm_private_dns_zone" "psql_dns_zone" {
#   name                = "privatelink.postgres.database.azure.com"
#   resource_group_name = data.azurerm_resource_group.rg.name
# }

# # https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html
# resource "azurerm_private_endpoint" "psql_endpoint" {
#   name                = format("%s-psql-endpoint", local.prefix)
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   subnet_id           = azurerm_subnet.private_link_services.id

#   # private_dns_zone_group {
#   #   name = "private-dns-zone-group"
#   #   private_dns_zone_ids = [
#   #     azurerm_private_dns_zone.psql_dns_zone.id
#   #   ]
#   # }

#   # https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource
#   private_service_connection {
#     name                           = "psql-private-link"
#     private_connection_resource_id = azurerm_postgresql_server.dbserver.id
#     is_manual_connection           = false
#     subresource_names              = ["postgresqlServer"]
#   }
# }

# # https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone_virtual_network_link.html
# resource "azurerm_private_dns_zone_virtual_network_link" "psql_vnet_link" {
#   name                  = format("%s-dns-zone-vnet-link", local.prefix)
#   resource_group_name   = data.azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.psql_dns_zone.name
#   virtual_network_id    = azurerm_virtual_network.network.id
# }
