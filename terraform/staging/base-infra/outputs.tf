output "environment" {
  description = "Environment this state describes (workspace name, or var.env in the default workspace)."
  value       = local.env
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command that writes a kubeconfig entry for the cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint (HTTPS)."
  value       = "https://${module.opensearch_logging.endpoint}"
}

output "opensearch_dashboards_url" {
  description = "OpenSearch Dashboards URL."
  value       = "https://${module.opensearch_logging.dashboard_endpoint}"
}

output "saml_sp_entity_id" {
  description = "Enter in Entra ID as Identifier (Entity ID)."
  value       = module.opensearch_logging.saml_sp_entity_id
}

output "saml_acs_url" {
  description = "Enter in Entra ID as Reply URL (Assertion Consumer Service URL)."
  value       = module.opensearch_logging.saml_acs_url
}

output "opensearch_master_username" {
  description = "OpenSearch internal master user (break-glass)."
  value       = module.opensearch_logging.master_username
}

output "opensearch_master_password" {
  description = "OpenSearch internal master password (break-glass). Read with: terraform output -raw opensearch_master_password"
  value       = module.opensearch_logging.master_password
  sensitive   = true
}

output "fluent_bit_role_arn" {
  description = "IAM role assumed by Fluent Bit through IRSA and mapped to the fluent_bit_writer OpenSearch role."
  value       = aws_iam_role.fluent_bit.arn
}
