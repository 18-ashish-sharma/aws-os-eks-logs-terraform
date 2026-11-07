locals {
  cluster_name     = join("-", [var.cluster_name, var.env])
  nodegroup1_label = join("-", ["ng1", var.env])

  # One EKS access entry per admin role (replaces the old aws-auth ConfigMap).
  admin_access_entries = {
    for idx, arn in var.cluster_admin_role_arns : "admin-${idx}" => {
      principal_arn = arn
      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
