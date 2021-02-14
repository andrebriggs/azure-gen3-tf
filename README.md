# Gen3 Azure Infrastructure Deployment

This repository contains the [Terraform](https://www.terraform.io/) that fully deploy and configure the infrastructure required to deploy a single instance of [Gen3](http://www.gen3.org) on Azure.

## Requirements

* `terraform` version `v0.14.6` was used for this repo. Version 0.13 and greater should work
* A shell environment, preferrably bash
* Necessary Azure subscription role assignments to create service principals and assign roles.

## Configuration

The [`variables.tf`](./variables.tf) file contains all of configuration options available for this template. All `terraform variables` are configured as `defaults` in [`variables.tf`](./variables.tf) or through Azure DevOps variables. See `bootstrap-gen3-azdo-tf` repository for more information on how those values are configured in Azure DevOps.

## Azure Resources

This is an overview of the Services deployed through this deployment. The authoritative list will live in the `*.tf` files in this repository, but the tables below give a good overview.

### Managed Services

| Azure Resource | Terraform Resource Type | Description |
| --- | --- | --- |
| Managed Kubernetes | `azurerm_kubernetes_cluster` | Azure's managed `k8s` |
| PSQL Server | `azurerm_postgresql_server` | Azure's managed Postgres DB |
<!-- | KeyVault | `azurerm_key_vault` | Azure's Key Management Service. All secrets required by the application, such as its signing key and DB access credentials, are provisioned automatically using Terraform into this KeyVault. | -->

> **Note**: to learn more about the use of Managed Identity in this deployment, refer to the [Managed Identity](./docs/MANAGED_IDENTITY.md) documentation

### Security

| Azure Resource | Terraform Resource Type | Description |
| --- | --- | --- |
| Role Assignment | `azurerm_role_assignment` | Manages fine-grained security for the Managed Identities under which the `k8s` pods and cluster run |

### Network

| Azure Resource | Terraform Resource Type | Description |
| --- | --- | --- |
| PSQL Virtual Network Rule | `azurerm_postgresql_virtual_network_rule` | Enables access from within the VNET that the clsuter runs in |
| Virtual Network | `azurerm_virtual_network` | A private network that the cluster runs in |
<!-- | CNAME Records | `azurerm_dns_cname_record` | DNS records for Azure Front Door | -->
<!-- | PSQL DB Firewall Rule | `azurerm_postgresql_firewall_rule` | Blocks access from external IPs | -->

### Obeservability

| Azure Resource | Terraform Resource Type | Description |
| --- | --- | --- |
| Log Analytics Solution | `azurerm_log_analytics_solution` | A collection point for Azure logs and telemetry |
| Log Analytics Workspace | `azurerm_log_analytics_workspace` | A workspace to create observability dashboards |
<!-- | Log Analytics Workbook | `azurerm_template_deployment` | ARM template for dashboard | -->

## Automated CICD (TODO)

**NOTE**: We use Terraform [workspaces](https://www.terraform.io/docs/language/state/workspaces.html) to switch between environments

(_More to come_)

## Manual Instructions for "First Time Run"

### 1. Disable backend state

For the **first** deployment, the contents of `backend.tf` will need to be commented out. Don't worry -- we'll uncomment this later.

```bash
# Comment out all lines in backend.tf
$ sed -i '' 's/^/#/' backend.tf
<file commented> 

# Verify file is commented out
$ cat backend.tf
```

### 2. Configure your environment

```bash
# Make a copy of the `.env.template` file named `.env`
$ cp .env.template .env

# Replace all occurences of "**REPLACE_ME**" in .env file using editor of choice (VS Code in this case)
# NOTE: Reference the bootstrap terraform repo for some values
$ code .env

# Once the .env has the correct values dot source the file
$ . .env

# Log into the Azure CLI
$ az login

# Set your default subscription - this will dictate where resources will be provisioned
$ az account set --subscription "<your subscription ID>"
```

### 3. Run the deployment

```bash
# Initialize the Terraform environment
$ terraform init

# See what the deployment will do. No changes will be applied, but you can review the changes that will be applied in the next step
$ terraform plan

# Deploy the changes. Choose 'yes' when prompted
$ terraform apply

```

### 4. Enable backend state

Enabling backend state will store the deployment state in Azure. This will allow others to run the deployment without you needing to worry about the state configuration.

Start by uncommenting the contents of `backend.tf`

```bash
# Uncomment all lines in backend.tf
$ sed -i '' 's/^##*//' backend.tf
<file uncommented> 

# Verify file is uncommented
$ cat backend.tf
```

Set the requested environment variables to access the backend state

```bash
# Get the access key for the storage account created in the bootstrap process
$ export ARM_ACCESS_KEY=<REPLACE ME>

# Get the storage account name created in the bootstrap process
$ export ARM_ACCOUNT_NAME=<REPLACE ME>

# Most likely will be "tfstate-dev" if you are using a "dev" environment
$ export ARM_CONTAINER_NAME=<REPLACE ME>

# Initialize the deployment with the backend
$ terraform init -backend-config "storage_account_name=${ARM_ACCOUNT_NAME}" -backend-config "container_name=${ARM_CONTAINER_NAME}"
```

You should see something along the lines of the following, to which you want to answer `yes`:

```bash
Do you want to copy existing state to the new backend?
```

If things work, you will see the following message and the state file should end up in Azure:

```bash
Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.
```

🎉 **Congratulations!** 🎉 You have now deployed the Azure managed resources needed for a Gen3 data common.

> **Next Steps**: Next get your CI/CD pipelines working to deploy applications. This will be covered in another repo!

## TODO

- [ ] Create pipelines
- [ ] Add Azure KeyVault
- [ ] Add PSQL DB Firewall Rule
- [ ] Add Log Analytics Workbook
- [ ] Add CNAME Records and Frontdoor?
- [ ] Add Managed Identities for CSI Driver

