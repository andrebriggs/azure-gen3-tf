
locals {
  cluster_name        = format("%s-aks", local.prefix)
  kubeconfig_filename = "kube_config"
  oms_agent_enabled   = true
}

module "aks" {
  source = "./modules/aks"

  resource_group_name = data.azurerm_resource_group.rg.name
  msi_enabled         = true
  cluster_name        = local.cluster_name
  dns_prefix          = local.cluster_name

  agent_vm_count     = var.kube_agent_vm_count
  agent_vm_size      = var.kube_agent_vm_size
  kubernetes_version = var.kube_version

  vnet_subnet_id = azurerm_subnet.subnet.id
  ssh_public_key = var.kube_pub_key

  output_directory    = var.output_directory
  kubeconfig_filename = local.kubeconfig_filename
  oms_agent_enabled   = true

  # TODO: Uncomment this
  # api_server_authorized_ip_ranges = concat(
  #   var.kube_api_server_authorized_ip_ranges,
  #   [format("%s/32", azurerm_public_ip.ops_outbound_pip.ip_address)]
  # )

  tags = local.tags
}

module "flux" {
  source = "./modules/flux"

  flux_image_tag              = "1.19.0"
  gitops_ssh_url              = var.gitops_ssh_url
  gitops_ssh_key_path         = var.gitops_ssh_key_path
  gitops_ssh_known_hosts_path = var.gitops_ssh_known_hosts_path
  gitops_label                = format("flux-sync-%s", var.env)
  gitops_path                 = var.env
  gitops_url_branch           = "master"
  output_directory            = var.output_directory
  kubeconfig_filename         = local.kubeconfig_filename
  flux_clone_dir              = "${local.cluster_name}-flux"
  prometheus_enabled          = true

  # workaround for flux not supporting managed identity
  registry_scanning_disabled = true

  # workaround for lack of `depends_on` for Terraform modules
  flux_dependencies = module.aks.kubeconfig_done
}

module "kubediff" {
  source = "./modules/kubediff"

  kubeconfig_complete = module.aks.kubeconfig_done
  gitops_ssh_url      = var.gitops_ssh_url
}

# https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
resource "azurerm_role_assignment" "acrpull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_id
}

# https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
data "azurerm_resource_group" "kube_rg" {
  name = module.aks.node_resource_group
}

# https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
resource "azurerm_role_assignment" "mi_operator" {
  scope                = data.azurerm_resource_group.kube_rg.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = module.aks.kubelet_id
}

resource "azurerm_role_assignment" "vm_contrib" {
  scope                = data.azurerm_resource_group.kube_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = module.aks.kubelet_id
}
