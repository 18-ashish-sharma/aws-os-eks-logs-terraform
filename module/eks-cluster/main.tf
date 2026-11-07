# IRSA role for the VPC CNI (aws-node). Giving the CNI its own role means the
# node IAM role does not need AmazonEKS_CNI_Policy (least privilege).
module "vpc_cni_irsa" {
  #checkov:skip=CKV_TF_1:Registry module pinned to an exact, immutable release version; bumps go through review.
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.8.2"

  name                  = "${local.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "eks" {
  #checkov:skip=CKV_TF_1:Registry module pinned to an exact, immutable release version; bumps go through review.
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  name               = local.cluster_name
  kubernetes_version = var.kubernetes_version

  # Control-plane logs to CloudWatch. "audit" is the security-relevant one.
  enabled_log_types                      = var.enabled_log_types
  cloudwatch_log_group_retention_in_days = var.eks_cloudwatch_log_group_retention_in_days

  # Public endpoint (restricted by CIDR) so CI/laptops can reach the API;
  # nodes use the private endpoint.
  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # Access: EKS access entries instead of the aws-auth ConfigMap.
  # The identity running Terraform gets admin so it can install Helm charts.
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true
  access_entries                           = local.admin_access_entries

  addons = {
    coredns = {
      most_recent = var.eks_most_recent_add_on
    }
    kube-proxy = {
      most_recent = var.eks_most_recent_add_on
    }
    vpc-cni = {
      # Install before nodes join so pods get IPs from the first boot.
      before_compute           = true
      most_recent              = var.eks_most_recent_add_on
      service_account_role_arn = module.vpc_cni_irsa.arn
    }
  }

  eks_managed_node_groups = {
    (var.nodegroup_name) = {
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = var.instance_types
      capacity_type  = var.use_spot_instances ? "SPOT" : "ON_DEMAND"

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      update_config = {
        max_unavailable_percentage = 50
      }

      # The CNI has its own IRSA role (above).
      iam_role_attach_cni_policy = false
      enable_monitoring          = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.node_disk_size
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      labels = {
        role = local.nodegroup1_label
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}"    = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role" = local.nodegroup1_label
      }
    }
  }

  tags = var.tags
}
