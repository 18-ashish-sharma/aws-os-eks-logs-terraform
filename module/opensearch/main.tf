module "opensearch" {
  source                                         = "cyberlabrs/opensearch/aws"
  version                                        = "1.0.6"
  name                                           = local.cluster_name
  region                                         = var.aws_region
  engine_version                                 = var.engine_version
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  node_to_node_encryption                        = true
  instance_type                                  = var.instance_type
  cluster_config = {
    instance_count           = var.instance_count
    dedicated_master_enabled = var.env == "prod" || var.env == "staging" ? true : false
    dedicated_master_count   = 3
    dedicated_master_type    = var.dedicated_master_type
  }
  encrypt_at_rest = {
    enabled = true
  }

  log_publishing_options = {
    index_logs_enabled                = var.index_logs_enabled
    application_logs_enabled          = var.index_logs_enabled
    application_logs_cw_log_group_arn = var.index_logs_cw_log_group_arn
    index_logs_cw_log_group_arn       = var.index_logs_cw_log_group_arn
  }

  custom_endpoint_enabled = var.custom_endpoint_enabled

  # Conditionally include custom endpoint configurations
  custom_endpoint = var.custom_endpoint_enabled ? "${var.env}-logging.${var.domain}" : null
  custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null

  zone_id = var.custom_endpoint_enabled ? var.zone_id : null

  create_linked_role = var.create_linked_role #variable to create the linked role
  volume_size        = var.volume_size
  volume_type        = var.volume_type
}
