output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA certificate of the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL of the cluster."
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider" {
  description = "OIDC issuer without the https:// prefix; used as the condition key prefix in IRSA trust policies."
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider; the federated principal in IRSA trust policies."
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "Security group ID attached to the worker nodes."
  value       = module.eks.node_security_group_id
}
