# Example values for staging. Copy to staging.tfvars (git-ignored) and edit.
region  = "ap-south-1"
project = "eks-logs"
env     = "staging"

vpc_cidr           = "10.20.0.0/16"
single_nat_gateway = true

kubernetes_version      = "1.34"
cluster_admin_role_arns = ["arn:aws:iam::123456789012:role/PlatformAdmin"]
eks_public_access_cidrs = ["203.0.113.0/24"] # your office / VPN / CI egress range
eks_instance_types      = ["t4g.large", "m6g.large"]
eks_use_spot_instances  = true
eks_min_size            = 2
eks_max_size            = 3
eks_desired_size        = 2

opensearch_instance_type            = "m6g.large.search"
opensearch_instance_count           = 2
opensearch_dedicated_master_enabled = false
opensearch_volume_size              = 100

# Optional custom hostname:
# opensearch_custom_endpoint                 = "logging.example.com"
# opensearch_custom_endpoint_certificate_arn = "arn:aws:acm:ap-south-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
# route53_zone_id                            = "Z0000000000000000000"

# SAML (second apply, after the Entra ID app exists):
saml_enabled = false
# saml_idp_entity_id       = "https://sts.windows.net/00000000-0000-0000-0000-000000000000/"
# saml_idp_metadata_path   = "./entra-federation-metadata.xml"
# saml_master_backend_role = "00000000-0000-0000-0000-000000000000"
