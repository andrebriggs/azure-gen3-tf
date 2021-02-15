variable "env" {
  type        = string
  description = "The name of the environment to provision. Examples: dev, qa, prod"
}

variable "region" {
  type        = string
  description = "The region in which to provision"
}

variable "service_name" {
  type        = string
  description = "A name to be used for all resource names and tags"
  default = "gen3"
}

variable "resource_group" {
  type        = string
  description = "The resource group to deploy into"
}

variable "acr_id" {
  type        = string
  description = "The resource identifier for AKS to attach to"
}

variable "psql_sku" {
  type        = string
  description = "The SKU to use for the provisioned PSQL instance"
}

variable "kube_agent_vm_count" {
  type    = string
  default = "3"
}

variable "kube_agent_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "kube_version" {
  type    = string
  default = "1.19.7"
}

variable "kube_pub_key" {
  type        = string
  description = "Kubernetes public key"
}

variable "kube_api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "Kubernetes API authorized IPv4 CIDR ranges"
  default     = []
}

variable "gitops_ssh_url" {
  type        = string
  description = "URL of git repo with Kubernetes manifests"
}

variable "gitops_ssh_known_hosts_path" {
  type        = string
  description = "File path to a known_hosts file, if you need to supply host key(s)"
  default     = ""
}

variable "gitops_ssh_key_path" {
  type        = string
  description = "GitOps ssh key path for Flux"
}

variable "output_directory" {
  type        = string
  description = "Directory for output files"
}

variable "ip_whitelist" {
  type        = list(string)
  description = "A whiltelist of IPs that should have access to resources provisioned into the virtual network"
  default = []
}