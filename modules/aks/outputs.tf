output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config.0.client_certificate
}

output "kube_config" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "kubeconfig_done" {
  value = join("", local_file.cluster_credentials.*.id)
}

output "resource_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "msi_client_id" {
  value = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}

output "kubelet_client_id" {
  value = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].client_id
}

output "kubelet_id" {
  value = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "kubelet_resource_id" {
  value = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].user_assigned_identity_id
}

output "log_analytics_solution_id" {
  value = azurerm_log_analytics_solution.solution.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.workspace.id
}
