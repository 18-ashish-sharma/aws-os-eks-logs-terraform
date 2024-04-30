variable "cluster_name" {
}

variable "kubernetes_version" {
  default = "1.29"
}

variable "instance_type" {
  default = "t4g.large"
}

variable "private_subnets" {
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "use_spot_instances" {
  description = "If set to true, the EKS cluster will use spot instances."
  type        = bool
  default     = true
}

variable "cluster_admin_role_arn" {
  default = "arn:aws:iam::095566081345:role/AWSReservedSSO_Developer_5314c26e244888b1"
}

variable "nodegroup_name" {
  default = "nodegroup1"
}

variable "desired_size" {
  default = "3"
}

variable "max_size" {
  default = "3"
}

variable "min_size" {
  default = "3"
}

variable "eks_cloudwatch_log_group_retention_in_days" {
  default = 90
}


variable "eks_most_recent_add_on" {
  default = false
}
