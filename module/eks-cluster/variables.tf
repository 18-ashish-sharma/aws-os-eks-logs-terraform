variable "cluster_name" {
  description = "Base name of the EKS cluster. The cluster is named <cluster_name>-<env>."
  type        = string
}

variable "env" {
  description = "Environment name (e.g. staging, prod). Appended to the cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Pick one in standard support; extended support is billed at a higher hourly rate."
  type        = string
  default     = "1.34"
}

variable "vpc_id" {
  description = "ID of the VPC the cluster runs in."
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for the control-plane ENIs and the worker nodes."
  type        = list(string)
}

variable "endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public Kubernetes API endpoint. Narrow this to office/VPN/CI ranges."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_admin_role_arns" {
  description = "IAM role ARNs granted cluster-admin through EKS access entries (e.g. an SSO admin role). The identity that runs Terraform is always admin."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for arn in var.cluster_admin_role_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:role/.+$", arn))])
    error_message = "Each entry must be an IAM role ARN, e.g. arn:aws:iam::123456789012:role/Admin."
  }
}

variable "enabled_log_types" {
  description = "EKS control-plane log types sent to CloudWatch."
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "eks_cloudwatch_log_group_retention_in_days" {
  description = "Retention, in days, for the EKS control-plane log group."
  type        = number
  default     = 90
}

variable "eks_most_recent_add_on" {
  description = "Track the most recent version of each EKS add-on. Leave false to keep add-on upgrades deliberate."
  type        = bool
  default     = false
}

variable "nodegroup_name" {
  description = "Name of the managed node group."
  type        = string
  default     = "nodegroup1"
}

variable "instance_types" {
  description = "Instance types for the node group (ARM/Graviton, to match the AL2023 ARM AMI). Several types improve Spot availability."
  type        = list(string)
  default     = ["t4g.large"]
}

variable "use_spot_instances" {
  description = "If true, the node group uses Spot capacity."
  type        = bool
  default     = true
}

variable "min_size" {
  description = "Minimum number of nodes."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes."
  type        = number
  default     = 3
}

variable "desired_size" {
  description = "Desired number of nodes at creation. Ignored by the module afterwards so an autoscaler can own it."
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Root EBS volume size for each node, in GiB."
  type        = number
  default     = 50
}

variable "tags" {
  description = "Extra tags applied to every resource in this module."
  type        = map(string)
  default     = {}
}
