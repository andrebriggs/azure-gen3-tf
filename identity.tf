# https://www.terraform.io/docs/providers/azurerm/r/user_assigned_identity.html
resource "azurerm_user_assigned_identity" "pi_fence" {
  resource_group_name = module.aks.node_resource_group
  location            = data.azurerm_resource_group.rg.location
  name                = "svc-fence-identity"
  tags                = local.tags
}

# resource "azurerm_user_assigned_identity" "cert_manager" {
#   resource_group_name = module.aks.node_resource_group
#   location            = data.azurerm_resource_group.rg.location
#   name                = "cert-manager-identity"
#   tags                = local.tags
# }

locals {
  identities_for_azure_cli_login = [
    azurerm_user_assigned_identity.pi_fence,
  ]

  identities_for_storage = [
  ]
}

# MI needs reader access to itself to enable MI login with CLI
#   https://github.com/MicrosoftDocs/azure-docs/issues/36664
# https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
resource "azurerm_role_assignment" "mi_reader" {
  count                = length(local.identities_for_azure_cli_login)
  scope                = local.identities_for_azure_cli_login[count.index].id
  role_definition_name = "Reader"
  principal_id         = local.identities_for_azure_cli_login[count.index].principal_id
}

# MI needs blob data contributor to access the storage container
# https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
# Pllaceholder for any Gen3 apps that need acces to Azure Storage

# resource "azurerm_role_assignment" "cert_manager_dns_zone" {
#   scope                = data.azurerm_dns_zone.dns.id
#   role_definition_name = "DNS Zone Contributor"
#   principal_id         = azurerm_user_assigned_identity.cert_manager.principal_id
# }
