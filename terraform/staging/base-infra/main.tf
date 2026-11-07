data "aws_availability_zones" "available" {
  #checkov:skip=CKV_AWS_394:Only the first three AZ names are used (slice below); a newly added AZ sorts after them and does not change the selection.
  state = "available"
}

# ---------------------------------------------------------------------------
# Network: 3 AZs, private subnets for nodes, public subnets for NAT / LBs.
# ---------------------------------------------------------------------------
module "vpc" {
  #checkov:skip=CKV_TF_1:Registry module pinned to an exact, immutable release version; bumps go through review.
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = local.name
  cidr = var.vpc_cidr
  azs  = local.azs

  private_subnets = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 8, 48 + i)]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags the AWS Load Balancer Controller uses to discover subnets.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ---------------------------------------------------------------------------
# EKS cluster.
# ---------------------------------------------------------------------------
module "eks" {
  source = "../../../module/eks-cluster"

  cluster_name       = var.project
  env                = local.env
  kubernetes_version = var.kubernetes_version

  vpc_id                       = module.vpc.vpc_id
  private_subnets              = module.vpc.private_subnets
  endpoint_public_access_cidrs = var.eks_public_access_cidrs
  cluster_admin_role_arns      = var.cluster_admin_role_arns

  instance_types     = var.eks_instance_types
  use_spot_instances = var.eks_use_spot_instances
  min_size           = var.eks_min_size
  max_size           = var.eks_max_size
  desired_size       = var.eks_desired_size

  eks_cloudwatch_log_group_retention_in_days = var.eks_log_retention_days
}

# ---------------------------------------------------------------------------
# OpenSearch domain that receives the pod logs.
# ---------------------------------------------------------------------------
module "opensearch_logging" {
  source = "../../../module/opensearch"

  cluster_name   = var.project
  env            = local.env
  engine_version = var.opensearch_engine_version

  instance_type            = var.opensearch_instance_type
  instance_count           = var.opensearch_instance_count
  dedicated_master_enabled = var.opensearch_dedicated_master_enabled
  dedicated_master_type    = var.opensearch_dedicated_master_type
  volume_size              = var.opensearch_volume_size
  volume_type              = var.opensearch_volume_type
  log_retention_days       = var.opensearch_log_retention_days

  saml = var.saml_enabled ? {
    idp_entity_id       = var.saml_idp_entity_id
    idp_metadata_xml    = file(var.saml_idp_metadata_path)
    master_backend_role = var.saml_master_backend_role
  } : null

  custom_endpoint                 = var.opensearch_custom_endpoint
  custom_endpoint_certificate_arn = var.opensearch_custom_endpoint_certificate_arn
  zone_id                         = var.route53_zone_id
}
