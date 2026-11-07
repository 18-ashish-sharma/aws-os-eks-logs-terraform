# Pod logs -> Fluent Bit (DaemonSet) -> OpenSearch, authenticated with IRSA.
#
# 1. An IAM role that only the Fluent Bit service account can assume (IRSA).
# 2. That role may send HTTP requests to this one domain.
# 3. Inside OpenSearch, the role is mapped to a write-only role limited to the
#    log indices (fine-grained access control).
# 4. Fluent Bit signs its requests with SigV4 (awsAuth On), so no password is
#    stored in Helm values or Kubernetes secrets.

locals {
  fluent_bit_namespace       = "logging"
  fluent_bit_service_account = "fluent-bit"
}

data "aws_iam_policy_document" "fluent_bit_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:${local.fluent_bit_namespace}:${local.fluent_bit_service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fluent_bit" {
  name               = "${local.name}-fluent-bit"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_assume.json
}

data "aws_iam_policy_document" "fluent_bit_opensearch" {
  statement {
    actions   = ["es:ESHttpGet", "es:ESHttpHead", "es:ESHttpPost", "es:ESHttpPut"]
    resources = ["${module.opensearch_logging.domain_arn}/*"]
  }
}

resource "aws_iam_role_policy" "fluent_bit_opensearch" {
  name   = "opensearch-write"
  role   = aws_iam_role.fluent_bit.id
  policy = data.aws_iam_policy_document.fluent_bit_opensearch.json
}

# OpenSearch security role: write to the log indices, nothing else.
resource "opensearch_role" "fluent_bit" {
  role_name   = "fluent_bit_writer"
  description = "Fluent Bit: create and write ${var.log_index_prefix}-* indices"

  cluster_permissions = ["cluster_monitor", "cluster_composite_ops"]

  index_permissions {
    index_patterns  = ["${var.log_index_prefix}-*"]
    allowed_actions = ["create_index", "crud"]
  }

  depends_on = [module.opensearch_logging]
}

# Map the IAM role (the identity Fluent Bit signs as) to that security role.
resource "opensearch_roles_mapping" "fluent_bit" {
  role_name     = opensearch_role.fluent_bit.role_name
  description   = "IRSA role used by the Fluent Bit DaemonSet"
  backend_roles = [aws_iam_role.fluent_bit.arn]
}

resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-for-fluent-bit"
  version          = var.fluent_bit_chart_version
  namespace        = local.fluent_bit_namespace
  create_namespace = true

  # See https://github.com/aws/eks-charts/tree/master/stable/aws-for-fluent-bit
  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = local.fluent_bit_service_account
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.fluent_bit.arn
      }
    }

    # The chart ships logs to CloudWatch by default; send them to OpenSearch only.
    cloudWatchLogs = { enabled = false }

    opensearch = {
      enabled   = true
      host      = module.opensearch_logging.endpoint
      port      = "443"
      tls       = "On"
      awsAuth   = "On"
      awsRegion = var.region
      # Daily indices (<prefix>-YYYY.MM.DD) make retention a simple index delete.
      logstashFormat = "On"
      logstashPrefix = var.log_index_prefix
      # Kubernetes labels such as app.kubernetes.io/name contain dots, which
      # OpenSearch would read as nested objects and reject on type conflicts.
      replaceDots      = "On"
      suppressTypeName = "On"
      traceError       = "On"
    }
  })]

  depends_on = [
    opensearch_roles_mapping.fluent_bit,
    aws_iam_role_policy.fluent_bit_opensearch,
  ]
}
