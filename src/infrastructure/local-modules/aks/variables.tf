variable "cluster_name" {
  description = "The name of the AKS cluster to create. Changing this forces a new resource to be created."
  default     = "cluster01"
}

variable "location" {
  description = "The region where the AKS cluster will be created. Changing this forces a new resource to be created. Ensure all enabled Azure features are supported in the region selected."
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "The name of the resource group the AKS cluster resource will be created in."
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use when creating the managed cluster. If not specified, the latest recommended version will be used at provisioning time."
  default     = null
}

variable "dns_prefix" {
  description = "DNS prefix to use when creating the managed cluster. Changing this forces a new resource to be created. must contain between 3 and 45 characters, and can contain only letters, numbers, and hyphens. It must start with a letter and must end with a letter or a number. If left unset dns_prefix will default to equal the cluster_name."
  default     = null
}

locals {
  dns_prefix = var.dns_prefix == null ? lower(var.cluster_name) : var.dns_prefix
}

variable "api_server_authorized_ip_ranges" {
  description = "List of IP range(s) to whitelist for incoming traffic to the K8S API (master service). Supports single IPs and CIDR block notation."
  default     = []
}

variable "enable_pod_security_policy" {
  description = "Enable Kubernetes Pod Security Policy. Requires RBAC to be enabled on the cluster."
  default     = false
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes nodes should exist. Resource Group is created with the cluster and can not already exist. Changing this forces a new resource to be created."
  default     = null
}

variable "enable_private_link" {
  description = "Enable AKS cluster Private Link to provide private IP addessing to the Kubernes API on the VNET where the K8S cluster nodes are located. This is a preview service and requires registration of Microsoft.ContainerService/AKSPrivateLinkPreview. Review the documented limitations carefully prior to implementing. Note: this preview feature did receive thorough module testing."
  default     = false
}

variable "enable_MSI_nodes" {
  description = "Enable Managed Service Identities for the cluster resources."
  default     = false
}

variable "tags" {
  description = "Map of tags for AKS resources."
  default     = {}
}

###############################################################################
#### Default Node Pool Profile Block
###############################################################################
variable "default_node_pool_name" {
  description = "Unique name of to the default node pool. Changing this forces a new resource to be created."
  default     = "pool1"
}

variable "default_node_pool_vm_size" {
  description = "The instance size of each VM in the Agent Pool (e.g. Standard_F1). Changing this forces a new resource to be created."
  default     = "Standard_D2s_v3"
}

variable "default_node_pool_avability_zones" {
  description = "List of Availability Zones across which the Node Pool should be spread."
  default     = ["1", "2", "3"]
}

variable "default_node_pool_enable_node_public_ip" {
  description = "Enables assignment of public IPs to the default node pool VMs. This is a preview service and should be enabled with caution. Note: Functional testing of this module failed to deploy in multiple Azure regions."
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "The maximum number of pods that can run on each node. Network policy of Kubenet limit is 110 and azure is 250. The Azure CNI will allocate max IPs per node on the subnet. Configure with VMET and  subnet ranges that are able accommodate default_node_pool_max_pods x default_node_pool_count (or default_node_pool_max_count if autoscaling is enabled)."
  default     = "110"
}

variable "default_node_pool_node_taints" {
  description = "A list of Kubernetes taints to be configured on nodes in the default agent pool. WARNING: Adding taints to a cluster with a single node pool will block some system pods from starting and fail the cluster build."
  default     = []
}

variable "default_node_pool_os_disk_size_gb" {
  description = "The default node pool's node operating system disk size in GB."
  default     = "128"
}

variable "default_node_pool_type" {
  description = "The default node pool's type of Agent Pool. Possible values are AvailabilitySet and VirtualMachineScaleSets. Changing this forces a new resource to be created."
  default     = "VirtualMachineScaleSets"
}

variable "default_node_pool_subnet_id" {
  description = "The Azure resource ID of the subnet where the agents in the default node pool should be provisioned. Changing this forces a new resource to be created."
}

variable "default_node_pool_count" {
  description = "Number of Agents (VMs) in the Pool. Possible values must be in the range of 1 to 100."
  default     = "3"
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enables Kubernetes node autoscaler on the default node pool. Configure autoscaling by setting default_node_pool_max_count and default_node_pool_min_count variables."
  default     = false
}

variable "default_node_pool_max_count" {
  description = "Max node count for the default node pool. Note: This is only configured when default_node_pool_enable_auto_scaling is true."
  default     = "100"
}

variable "default_node_pool_min_count" {
  description = "Max node count for the default node pool. Note: This is only configured when default_node_pool_enable_auto_scaling is true."
  default     = "3"
}

###############################################################################
### Linux/Windows Profile Blocks
###############################################################################
variable "admin_username" {
  description = "The Linux or Windows admin username for cluster nodes. Changing this forces a new resource to be created."
  default     = "azureadmin"
}

variable "ssh_key_data" {
  description = "The local path to the SSH public key for admin_username."
  default     = null
}

variable "admin_password" {
  description = "The admin password for Windows agent node VMs. Windows agent nodes are a preview service and require registration of feature Microsoft.ContainerService/WindowsPreview."
  default     = null
}

###############################################################################
### Network Profile Block
###############################################################################
variable "network_plugin" {
  description = "Kubernetes network plugin configured on the cluster. Currently supported values are azure or kubenet. Changing this forces a new resource to be created."
  default     = "azure"
}

variable "network_policy" {
  description = "Kubernetes network policy configured on the cluster. Network policy allows for the control the traffic flow between pods. Currently supported values are calico or azure. Changing this forces a new resource to be created."
  default     = "azure"
}

variable "dns_service_ip" {
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns/core-dns). This is required when network_plugin is set to azure. Changing this forces a new resource to be created. **Default value is calculated to the 10th usable IP in the service_cidr IP block**"
  default     = null
}

locals {
  dns_service_ip = var.dns_service_ip == null ? cidrhost(var.service_cidr, 10) : var.dns_service_ip
}

variable "docker_bridge_cidr" {
  description = "IP address (in CIDR notation) used as the Docker bridge IP address on nodes. This is required when network_plugin is set to azure. Changing this forces a new resource to be created."
  default     = "172.17.0.1/16"
}

variable "service_cidr" {
  description = "The network IP range assigned to Kubernetes services. CIDR range must be smaller than a /12 subnet. This is required when network_plugin is set to azure. Changing this forces a new resource to be created."
  default     = "172.18.0.0/16"
}

variable "pod_cidr" {
  description = "The network range assigned to cluster pods in CIDR notation. This field should only be set when network_plugin is set to kubenet and the module will default to 172.16.0.0/16 if left unset. Changing this forces a new resource to be created."
  default     = null
}

locals {
  pod_cidr = (var.network_plugin == "kubenet" && var.pod_cidr == null) ? "172.16.0.0/16" : var.pod_cidr
}

variable "lb_sku" {
  description = " Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Supported values are basic or standard."
  default     = "standard"
}

variable "lb_managed_outbound_ip_count" {
  description = "Count of desired managed outbound IPs for the cluster load balancer. Must be in the range between 1-100. Note: This value is only supported with standard SKU load balancer (lb_sku variable)."
  default     = null
}

variable "lb_ip_prefix_ids" {
  description = "The ID of the outbound Public IP Address Prefixes to use for cluster load balancer. lb_ip_prefix_id and lb_ip_address_id are mutually exclusive. Module will default to lb_ip_prefix_id if both are defined."
  default     = null
}

variable "lb_ip_address_ids" {
  description = "The ID of the Public IP Addresses which should be used for outbound communication for the cluster load balancer. Public IPs must configured with standard SKU when used with standard SKU load balancer. lb_managed_outbound_ip_count, lb_ip_prefix_id and lb_ip_address_id are all mutually exclusive.  Module will default tlb_ip_prefix_id if both are defined."
  default     = null
}

###############################################################################
### service_principal block
###############################################################################
variable "client_id" {
  description = "The Client ID for the Service Principal. Changing this forces a new resource to be created."
  default     = null
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal. Changing this forces a new resource to be created."
  default     = null
}

###############################################################################
### role_based_access_control block
###############################################################################
variable "enable_rbac" {
  description = " Enables RBAC AKS cluster. Note: The following are required input vars when enabled: client_app_id, server_app_id, server_app_secret. Changing this forces a new resource to be created."
  default     = "true"
}

variable "client_app_id" {
  description = "The Client ID of an Azure Active Directory Application. Changing this forces a new resource to be created."
  default     = null
}

variable "server_app_id" {
  description = "The Server ID of an Azure Active Directory Application. Changing this forces a new resource to be created."
  default     = null
}

variable "server_app_secret" {
  description = "The Server Secret of an Azure Active Directory Application. Changing this forces a new resource to be created."
  default     = null
}

variable "tenant_id" {
  description = "The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used. Changing this forces a new resource to be created."
  default     = null
}

###############################################################################
### Add-ons Block
###############################################################################
variable "enable_aci_connector" {
  description = "Enables the virtual kubelet ACI connector provider addon. Note: aci_subnet_name input variable is required when ACI addon is enabled."
  default     = false
}

variable "aci_subnet_name" {
  description = "The subnet name for the virtual kubelet nodes to run. AKS will add a delegation to this subnet. To prevent TF config thrashing, ensure the subnet created for virtual nodes has an aciDelegation delegation configured on this subnet."
  default     = null
}

variable "enable_oms" {
  description = "Enables deploying the OMS agent integration daemonset on the cluster nodes."
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace which the OMS Agent should send data to. Note: This is required when the OMS addon is enabled."
  default     = null
}

variable "enable_azure_policy" {
  description = "Enables Azure Cloud Policy integration for AKS. Still in preview and requires registration of Microsoft.ContainerService/AKS-AzurePolicyAutoApprove and Microsoft.PolicyInsights/AKS-DataplaneAutoApprove."
  default     = false
}

variable "enable_http_application_routing" {
  description = "Enables HTTP Application Routing. Changing this forces a cluster rebuild."
  default     = false
}

variable "enable_kube_dashboard" {
  description = "Enables deployment of the Kubernetes Dashboard pod."
  default     = false
}
