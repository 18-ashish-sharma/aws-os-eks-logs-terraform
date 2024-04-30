data "aws_caller_identity" "current" {}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  vpc_cni_enable_ipv4   = true
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = false

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15.4"

  cluster_name                    = local.cluster_name
  cluster_version                 = var.kubernetes_version
  cluster_enabled_log_types       = ["api", "controllerManager", "scheduler"]
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_tags = {
    Name = local.cluster_name
  }

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      most_recent = var.eks_most_recent_add_on
    }
    kube-proxy = {
      most_recent = var.eks_most_recent_add_on
    }
    vpc-cni    = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      most_recent = var.eks_most_recent_add_on
    }
  }

  vpc_id                    = var.vpc_id
  subnet_ids                = var.private_subnets
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn = var.cluster_admin_role_arn
      username = "cluster-admin"
      groups   = ["system:masters"]
    }
  ]

  #  aws_auth_users            = local.cluster_users

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_groups = {

    "${var.nodegroup_name}" = {
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
      instance_types = [var.instance_type]
      capacity_type  = var.use_spot_instances ? "SPOT" : "ON_DEMAND"
      update_config  = {
        max_unavailable_percentage = 50
      }
      labels = {
        role = local.nodegroup1_label
      }
      ami_type                   = "AL2_ARM_64"
      disk_size                  = 50
      iam_role_attach_cni_policy = true
      enable_monitoring          = true

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${local.cluster_name}"    = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role" = local.nodegroup1_label
      }
    }
  }
  cloudwatch_log_group_retention_in_days = var.eks_cloudwatch_log_group_retention_in_days
}
