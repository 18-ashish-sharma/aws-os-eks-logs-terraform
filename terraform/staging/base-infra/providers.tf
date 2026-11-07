provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

# Helm talks to the new cluster with a short-lived token from `aws eks get-token`
# (needs the AWS CLI where Terraform runs). No kubeconfig file is involved.
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

# The OpenSearch provider manages security roles inside the domain (the
# Security plugin API), authenticating as the internal master user.
provider "opensearch" {
  url               = "https://${module.opensearch_logging.endpoint}"
  username          = module.opensearch_logging.master_username
  password          = module.opensearch_logging.master_password
  aws_region        = var.region
  sign_aws_requests = false
  healthcheck       = false
}
