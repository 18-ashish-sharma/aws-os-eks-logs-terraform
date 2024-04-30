variable "cluster_name" {
  type    = string
  default = "opensearch"
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "env" {
  type = string
}

variable "create_linked_role" {
  default = true
}

variable "instance_type" {
  default = "t3.small.search"
}

variable "instance_count" {
  default = 3
}

variable "volume_size" {
  default = 10
}

variable "volume_type" {
  default = "gp2"
}

variable "dedicated_master_type" {
  default = "c6g.large.search"
}

variable "index_logs_cw_log_group_arn" {
  default = ""
}

variable "index_logs_enabled" {
  default = false
}

variable "engine_version" {
  default = "OpenSearch_1.3"
}

variable "custom_endpoint_enabled" {
  default = false
}

variable "zone_id" {
  default = ""
}

variable "custom_endpoint_certificate_arn" {
  default = ""
}

variable "domain" {
  default = ""
}
