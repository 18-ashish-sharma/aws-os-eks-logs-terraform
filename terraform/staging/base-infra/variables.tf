# --- General -----------------------------------------------------------------

variable "region" {
  description = "AWS region for every resource in this stack."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Short project name; prefix for the VPC, EKS cluster and OpenSearch domain (<project>-<env>)."
  type        = string
  default     = "eks-logs"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,15}$", var.project))
    error_message = "project must be 2-16 lowercase letters, digits or hyphens, starting with a letter (OpenSearch domain names are limited to 28 characters)."
  }
}

variable "env" {
  description = "Environment name used when the Terraform workspace is \"default\". In any other workspace, the workspace name is used instead."
  type        = string
  default     = "staging"
}

# --- Network -----------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block of the VPC. Private subnets take /20s from the start, public subnets /24s higher up."
  type        = string
  default     = "10.20.0.0/16"
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for all AZs (cheaper) instead of one per AZ (survives an AZ outage)."
  type        = bool
  default     = true
}

# --- EKS ---------------------------------------------------------------------

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Keep it in standard support to avoid extended-support charges."
  type        = string
  default     = "1.34"
}

variable "cluster_admin_role_arns" {
  description = "IAM role ARNs (e.g. an SSO admin role) given cluster-admin via EKS access entries."
  type        = list(string)
  default     = []
}

variable "eks_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_instance_types" {
  description = "Graviton (ARM) instance types for the managed node group."
  type        = list(string)
  default     = ["t4g.large", "m6g.large"]
}

variable "eks_use_spot_instances" {
  description = "Run the node group on Spot capacity."
  type        = bool
  default     = true
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes at creation."
  type        = number
  default     = 2
}

variable "eks_log_retention_days" {
  description = "Retention, in days, for EKS control-plane logs in CloudWatch."
  type        = number
  default     = 30
}

# --- OpenSearch --------------------------------------------------------------

variable "opensearch_engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_2.11"
}

variable "opensearch_instance_type" {
  description = "OpenSearch data node instance type."
  type        = string
  default     = "m6g.large.search"
}

variable "opensearch_instance_count" {
  description = "Number of OpenSearch data nodes (1, or an even number for two AZs)."
  type        = number
  default     = 2
}

variable "opensearch_dedicated_master_enabled" {
  description = "Run three dedicated master nodes (recommended for production)."
  type        = bool
  default     = false
}

variable "opensearch_dedicated_master_type" {
  description = "Instance type for dedicated master nodes."
  type        = string
  default     = "c6g.large.search"
}

variable "opensearch_volume_size" {
  description = "EBS volume size per OpenSearch data node, in GiB."
  type        = number
  default     = 100
}

variable "opensearch_volume_type" {
  description = "EBS volume type for OpenSearch data nodes."
  type        = string
  default     = "gp3"
}

variable "opensearch_log_retention_days" {
  description = "Retention, in days, for the OpenSearch domain's own application/audit logs in CloudWatch."
  type        = number
  default     = 30
}

variable "opensearch_custom_endpoint" {
  description = "Optional custom hostname for the domain, e.g. logging.example.com."
  type        = string
  default     = null
}

variable "opensearch_custom_endpoint_certificate_arn" {
  description = "ACM certificate ARN for opensearch_custom_endpoint."
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID for the custom endpoint CNAME."
  type        = string
  default     = null
}

# --- SAML (Microsoft Entra ID) ----------------------------------------------

variable "saml_enabled" {
  description = "Enable SAML login for OpenSearch Dashboards. Requires the three saml_* inputs below."
  type        = bool
  default     = false

  validation {
    condition     = !var.saml_enabled || (var.saml_idp_entity_id != null && var.saml_idp_metadata_path != null && var.saml_master_backend_role != null)
    error_message = "saml_enabled = true needs saml_idp_entity_id, saml_idp_metadata_path and saml_master_backend_role."
  }
}

variable "saml_idp_entity_id" {
  description = "IdP entity ID (Entra ID: \"Microsoft Entra Identifier\", e.g. https://sts.windows.net/<tenant-id>/)."
  type        = string
  default     = null
}

variable "saml_idp_metadata_path" {
  description = "Path to the IdP federation metadata XML file downloaded from Entra ID."
  type        = string
  default     = null
}

variable "saml_master_backend_role" {
  description = "Entra ID group object ID whose members become OpenSearch admins."
  type        = string
  default     = null
}

# --- Fluent Bit --------------------------------------------------------------

variable "fluent_bit_chart_version" {
  description = "Version of the aws-for-fluent-bit Helm chart."
  type        = string
  default     = "0.1.35"
}

variable "log_index_prefix" {
  description = "Prefix of the daily pod-log indices (<prefix>-YYYY.MM.DD)."
  type        = string
  default     = "eks-pod-logs"
}
