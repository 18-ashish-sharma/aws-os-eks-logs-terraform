variable "bucket_name" {
  description = "Short project slug used to build the bucket and lock-table names: terraform-<bucket_name>-<env>-state. S3 bucket names are global, so make it unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-32 lowercase letters, digits or hyphens."
  }
}

variable "env" {
  description = "Environment name (e.g. staging, prod). Part of every resource name."
  type        = string
}

variable "project" {
  description = "Value for the Project tag."
  type        = string
  default     = "eks-logs"
}

variable "module_name" {
  description = "Value for the Subproject tag: the root module whose state this bucket holds."
  type        = string
  default     = "base-infra"
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep old (noncurrent) state file versions before S3 deletes them."
  type        = number
  default     = 90
}
