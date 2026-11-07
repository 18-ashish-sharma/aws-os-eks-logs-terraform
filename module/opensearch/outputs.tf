output "domain_name" {
  description = "Name of the OpenSearch domain."
  value       = aws_opensearch_domain.this.domain_name
}

output "domain_arn" {
  description = "ARN of the OpenSearch domain. Use <arn>/* in IAM policies."
  value       = aws_opensearch_domain.this.arn
}

output "endpoint" {
  description = "Domain endpoint hostname (no scheme), used by Fluent Bit and API clients."
  value       = aws_opensearch_domain.this.endpoint
}

output "dashboard_endpoint" {
  description = "OpenSearch Dashboards hostname and path (no scheme)."
  value       = aws_opensearch_domain.this.dashboard_endpoint
}

output "saml_sp_entity_id" {
  description = "Service provider entity ID to enter in the IdP as the Identifier."
  value       = "https://${aws_opensearch_domain.this.endpoint}"
}

output "saml_acs_url" {
  description = "SP-initiated SSO / Assertion Consumer Service URL to enter in the IdP as the Reply URL."
  value       = "https://${aws_opensearch_domain.this.endpoint}/_dashboards/_opendistro/_security/saml/acs"
}

output "master_username" {
  description = "Internal master user name."
  value       = var.master_user_name
}

output "master_password" {
  description = "Internal master user password. Stored in state; read with `terraform output -raw`."
  value       = random_password.master.result
  sensitive   = true
}
