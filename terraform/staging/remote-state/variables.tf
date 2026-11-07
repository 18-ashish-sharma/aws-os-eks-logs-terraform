variable "region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "Project slug for the bucket name: terraform-<bucket_name>-<env>-state. Must make the bucket name globally unique."
  type        = string
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "project" {
  description = "Value for the Project tag."
  type        = string
  default     = "eks-logs"
}
