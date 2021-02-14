# https://www.terraform.io/docs/providers/azurerm/r/storage_account.html
resource "azurerm_storage_account" "sa" {
  name                     = substr(replace(format("%s-storage", local.prefix), "-", ""), 0, 24)
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_replication_type = "GRS"
  account_tier             = "Standard"
  allow_blob_public_access = true
  tags                     = local.tags
}

# https://www.terraform.io/docs/providers/azurerm/r/storage_container.html
resource "azurerm_storage_container" "example" {
  name                  = format("%s-container", local.prefix)
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "blob"
}

