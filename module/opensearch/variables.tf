variable "cluster_name" {
  description = "Base name of the OpenSearch domain. The domain is named <cluster_name>-<env>."
  type        = string
  default     = "opensearch"
}

variable "env" {
  description = "Environment name (e.g. staging, prod). Appended to the domain name."
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version, e.g. OpenSearch_2.11."
  type        = string
  default     = "OpenSearch_2.11"
}

variable "instance_type" {
  description = "Data node instance type."
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of data nodes. Use an even number > 1 to spread across two AZs."
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count == 1 || var.instance_count % 2 == 0
    error_message = "instance_count must be 1, or an even number so nodes split evenly across two AZs."
  }
}

variable "dedicated_master_enabled" {
  description = "Run three dedicated master nodes. Recommended for staging/prod; adds cost."
  type        = bool
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type for dedicated master nodes (used only when dedicated_master_enabled = true)."
  type        = string
  default     = "c6g.large.search"
}

variable "volume_size" {
  description = "EBS volume size per data node, in GiB."
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "EBS volume type for data nodes."
  type        = string
  default     = "gp3"
}

variable "master_user_name" {
  description = "Name of the internal master user (used for break-glass access and by Terraform to manage security roles)."
  type        = string
  default     = "admin"
}

variable "log_retention_days" {
  description = "Retention, in days, for the domain's application and audit log groups in CloudWatch."
  type        = number
  default     = 30
}

variable "saml" {
  description = <<-EOT
    SAML (e.g. Microsoft Entra ID) settings for OpenSearch Dashboards. Leave null to skip.
    idp_entity_id       - the IdP "Azure AD Identifier" / entity ID.
    idp_metadata_xml    - contents of the IdP federation metadata XML.
    master_backend_role - IdP group ID whose members become OpenSearch admins.
    roles_key           - SAML attribute that carries the user's groups.
  EOT
  type = object({
    idp_entity_id           = string
    idp_metadata_xml        = string
    master_backend_role     = string
    roles_key               = optional(string, "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups")
    session_timeout_minutes = optional(number, 60)
  })
  default = null
}

variable "custom_endpoint" {
  description = "Optional custom hostname for the domain, e.g. logging.example.com. Requires custom_endpoint_certificate_arn and zone_id."
  type        = string
  default     = null
}

variable "custom_endpoint_certificate_arn" {
  description = "ACM certificate ARN covering custom_endpoint."
  type        = string
  default     = null
}

variable "zone_id" {
  description = "Route 53 hosted zone ID in which to create the custom_endpoint CNAME."
  type        = string
  default     = null
}

variable "tags" {
  description = "Extra tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}
