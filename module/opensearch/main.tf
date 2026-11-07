data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Master user password. It is generated here, so it lives in Terraform state:
# the state bucket must stay encrypted and access-controlled.
# ---------------------------------------------------------------------------
resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%*()-_=+[]{}:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

# ---------------------------------------------------------------------------
# CloudWatch log groups for the domain's own application and audit logs.
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  #checkov:skip=CKV_AWS_158:Log groups use CloudWatch's default encryption; a customer-managed KMS key is a follow-up.
  #checkov:skip=CKV_AWS_338:Retention is a variable (default 30 days) to control cost; set log_retention_days = 365 where policy requires it.
  for_each = toset(["application", "audit"])

  name              = "/aws/opensearch/${local.domain_name}/${each.key}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}

data "aws_iam_policy_document" "log_publishing" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:PutLogEventsBatch"]
    resources = [for lg in aws_cloudwatch_log_group.this : "${lg.arn}:*"]

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name     = "${local.domain_name}-opensearch-logs"
  policy_document = data.aws_iam_policy_document.log_publishing.json
}

# ---------------------------------------------------------------------------
# The domain.
# ---------------------------------------------------------------------------
resource "aws_opensearch_domain" "this" {
  #checkov:skip=CKV_AWS_247:Encrypted at rest with the AWS-managed key; a customer-managed KMS key is a follow-up.
  #checkov:skip=CKV_AWS_137:Public endpoint by design so browsers can reach Dashboards over SAML; FGAC + HTTPS-only + TLS 1.2 guard it. Move into the VPC for prod.
  #checkov:skip=CKV_AWS_318:Zone awareness and dedicated masters are variables; staging defaults favour cost (see README).
  #checkov:skip=CKV_AWS_248:Not a VPC domain, so no security group applies (see CKV_AWS_137).
  #checkov:skip=CKV2_AWS_59:Dedicated masters are a variable (dedicated_master_enabled), off by default for cost.
  domain_name    = local.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = local.zone_awareness

    dynamic "zone_awareness_config" {
      for_each = local.zone_awareness ? [1] : []
      content {
        availability_zone_count = 2
      }
    }

    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count   = var.dedicated_master_enabled ? 3 : null
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-PFS-2023-10"

    custom_endpoint_enabled         = var.custom_endpoint != null
    custom_endpoint                 = var.custom_endpoint
    custom_endpoint_certificate_arn = var.custom_endpoint_certificate_arn
  }

  # Fine-grained access control: every request is authenticated (internal
  # user, IAM SigV4 or SAML) and authorised against OpenSearch roles.
  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = random_password.master.result
    }
  }

  log_publishing_options {
    log_type                 = "ES_APPLICATION_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this["application"].arn
  }

  log_publishing_options {
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this["audit"].arn
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z][a-z0-9-]{2,27}$", local.domain_name))
      error_message = "OpenSearch domain name '${local.domain_name}' must be 3-28 lowercase characters and start with a letter. Shorten cluster_name or env."
    }
    precondition {
      condition     = var.custom_endpoint == null || (var.custom_endpoint_certificate_arn != null && var.zone_id != null)
      error_message = "custom_endpoint needs custom_endpoint_certificate_arn and zone_id."
    }
  }

  depends_on = [aws_cloudwatch_log_resource_policy.this]
}

# Resource policy: let requests reach the domain; FGAC decides what each
# authenticated identity may do. The domain ARN is only known after creation,
# so the policy is a separate resource.
data "aws_iam_policy_document" "access" {
  #checkov:skip=CKV_AWS_283:Standard pattern for an FGAC domain: the resource policy admits requests and fine-grained access control authenticates and authorises each one.
  statement {
    actions   = ["es:ESHttp*"]
    resources = ["${aws_opensearch_domain.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_opensearch_domain_policy" "this" {
  domain_name     = aws_opensearch_domain.this.domain_name
  access_policies = data.aws_iam_policy_document.access.json
}

# ---------------------------------------------------------------------------
# SAML single sign-on for OpenSearch Dashboards (optional).
# ---------------------------------------------------------------------------
resource "aws_opensearch_domain_saml_options" "this" {
  count = var.saml == null ? 0 : 1

  domain_name = aws_opensearch_domain.this.domain_name

  saml_options {
    enabled                 = true
    master_backend_role     = var.saml.master_backend_role
    roles_key               = var.saml.roles_key
    session_timeout_minutes = var.saml.session_timeout_minutes

    idp {
      entity_id        = var.saml.idp_entity_id
      metadata_content = var.saml.idp_metadata_xml
    }
  }
}

# ---------------------------------------------------------------------------
# Optional custom endpoint DNS record.
# ---------------------------------------------------------------------------
resource "aws_route53_record" "custom_endpoint" {
  count = var.custom_endpoint == null ? 0 : 1

  zone_id = var.zone_id
  name    = var.custom_endpoint
  type    = "CNAME"
  ttl     = 300
  records = [aws_opensearch_domain.this.endpoint]
}
