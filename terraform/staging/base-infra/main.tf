data "aws_caller_identity" "current" {}
# Logging configuration eks to opensearch

module "opensearch_logging" {
  cluster_name            = "opensearch-logging"
  source                  = "../../../module/opensearch"
  env                     = var.env
  create_linked_role      = var.create_linked_role
  instance_count          = var.opensearch_instance_type_count
  instance_type           = var.opensearch_instance_type
  volume_size             = var.opensearch_instance_volume_size
  volume_type             = var.opensearch_instance_volume_type
  engine_version          = var.opensearch_logging_engine_version
  custom_endpoint_enabled = true
}

# Helm Chart for Fluent Bit
resource "helm_release" "fluentbit" {
  name       = "fluentbit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "kube-system"

  values = [
    <<-EOT
    # OpenSearch host, awsRegion, httpUser and httpPasswd are dynamically
    # updated during provisioning.
    # CloudWatch logs are on by default and need to be turned off for this example
    # See https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit
    ---
    opensearch:
      enabled: true
      index: "eks-pod-logs"
      tls: "On"
      awsAuth: "Off"
      traceError: "On"
      host: "${module.opensearch_logging.kibana_endpoint}"
      awsRegion: "${var.region}"
      httpUser: "admin"
      httpPasswd: "${module.opensearch_logging.os_password}"
    
    cloudWatchLogs:
      enabled: false
    EOT
  ]
}

