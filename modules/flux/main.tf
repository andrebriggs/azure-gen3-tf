module "common-provider" {
  source = "../common-provider"
}

resource "null_resource" "deploy_flux" {
  count      = var.enable_flux ? 1 : 0
  depends_on = [var.flux_dependencies]

  provisioner "local-exec" {
    command = "KUBECONFIG=${var.output_directory}/${var.kubeconfig_filename} ${path.module}/deploy_flux.sh -b '${var.gitops_url_branch}' -f '${var.flux_repo_url}' -g '${var.gitops_ssh_url}' -h '${var.gitops_ssh_known_hosts_path}' -k '${var.gitops_ssh_key_path}' -d '${var.flux_clone_dir}' -c '${var.gitops_poll_interval}' -l '${var.gitops_label}' -e '${var.gitops_path}' -s '${var.acr_enabled}' -x '${var.registry_scanning_disabled}' -p '${var.prometheus_enabled}' -r '${var.flux_image_repository}' -t '${var.flux_image_tag}' -z '${var.gc_enabled}'"
  }

  triggers = {
    enable_flux                = var.enable_flux
    flux_recreate              = var.flux_recreate
    gitops_url_branch          = var.gitops_url_branch
    flux_repo_url              = var.flux_repo_url
    gitops_ssh_url             = var.gitops_ssh_url
    gitops_ssh_key_path        = var.gitops_ssh_key_path
    flux_clone_dir             = var.flux_clone_dir
    gitops_poll_interval       = var.gitops_poll_interval
    gitops_label               = var.gitops_label
    gitops_path                = var.gitops_path
    acr_enabled                = var.acr_enabled
    registry_scanning_disabled = var.registry_scanning_disabled
    prometheus_enabled         = var.prometheus_enabled
    flux_image_repository      = var.flux_image_repository
    flux_image_tag             = var.flux_image_tag
    gc_enabled                 = var.gc_enabled
    file_hash                  = filesha256("${path.module}/deploy_flux.sh")
  }
}
