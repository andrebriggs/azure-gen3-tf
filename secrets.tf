
# https://www.terraform.io/docs/providers/azurerm/d/client_config.html
data "azurerm_client_config" "current" {}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault.html
resource "azurerm_key_vault" "kv" {
  name                = format("%s-kv", local.prefix)
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = local.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions         = ["create", "delete", "get", "list", "update"]
    secret_permissions      = ["set", "delete", "get", "list"]
    certificate_permissions = ["create", "delete", "get", "list"]
  }

  # fence microservice needs access to secrets only
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.pi_fence.principal_id

    certificate_permissions = []
    key_permissions         = []
    secret_permissions      = ["get"]
  }

  # network_acls {
  #   bypass                     = "None"
  #   default_action             = "Deny"
  #   ip_rules                   = [for ip in var.ip_whitelist : format("%s/32", ip)]
  #   virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  # }
}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault_secret.html
resource "azurerm_key_vault_secret" "db_user" {
  name = "psql-user"
  value = format(
    "%s@%s",
    azurerm_postgresql_server.dbserver.administrator_login,
    azurerm_postgresql_server.dbserver.fqdn
  )
  key_vault_id = azurerm_key_vault.kv.id
  tags         = local.tags
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "psql-pass"
  value        = azurerm_postgresql_server.dbserver.administrator_login_password
  key_vault_id = azurerm_key_vault.kv.id
  tags         = local.tags
}

# resource "azurerm_key_vault_secret" "db_fqdn" {
#   name         = "psql-fqdn"
#   value        = azurerm_private_endpoint.psql_endpoint.private_dns_zone_configs[0].record_sets[0].fqdn
#   key_vault_id = azurerm_key_vault.kv.id
#   tags         = local.tags
# }

# https://www.terraform.io/docs/providers/azurerm/r/key_vault_key.html
resource "azurerm_key_vault_key" "signing_key" {
  name         = "signing-key"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "EC"
  curve        = "P-256"

  key_opts = [
    "sign",
    "verify",
  ]
}
