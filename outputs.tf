
##
# Kubernetes
##
output "kube_cluster_name" {
  value = local.cluster_name
}

output "kube_cluster_msi_client_id" {
  value = module.aks.msi_client_id
}

output "kube_cluster_kublet_client_id" {
  value = module.aks.kubelet_client_id
}

output "kube_resource_group" {
  value = module.aks.node_resource_group
}

##
# Keyvault
##
output "keyvault_name" {
  value = azurerm_key_vault.kv.name
}

##
# PSQL
##
output "db_name" {
  value = azurerm_postgresql_database.db.name
}

##
# Storage Account
##
output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

##
# Secrets
##
output "signing_key_name" {
  value = azurerm_key_vault_key.signing_key.name
}

# output "db_fqdn_secret_name" {
#   value = azurerm_key_vault_secret.db_fqdn.name
# }

output "db_user_secret_name" {
  value = azurerm_key_vault_secret.db_user.name
}

output "db_pass_secret_name" {
  value = azurerm_key_vault_secret.db_pass.name
}


##
# Identities
##
output "identity_fence" {
  value = azurerm_user_assigned_identity.pi_fence.name
}