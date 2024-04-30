variable "region" {
  default = "ap-south-1"  
}

variable "opensearch_instance_type" {
  default = "m6g.4xlarge.search"
}

variable "dedicated_master_type" {
  default = "c6g.large.search"
}

variable "opensearch_instance_volume_size" {
  default = 100
}

variable "opensearch_instance_volume_type" {
  default = "gp3"
}

variable "opensearch_instance_type_count" {
  default = 2
}

variable "opensearch_logging_engine_version" {
  default = "OpenSearch_2.11"
}

variable "create_linked_role" {
  default = false
}

variable "env" {
  default = "staging"
}
