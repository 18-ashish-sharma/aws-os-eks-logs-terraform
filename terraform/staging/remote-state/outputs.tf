output "state_bucket" {
  description = "S3 bucket for Terraform state."
  value       = module.remote_state.bucket_name
}

output "lock_table" {
  description = "DynamoDB table for state locking."
  value       = module.remote_state.lock_table_name
}

output "backend_config" {
  description = "Backend block to paste into base-infra/backend.tf."
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${module.remote_state.bucket_name}"
        key            = "base-infra/terraform.tfstate"
        region         = "${var.region}"
        encrypt        = true
        dynamodb_table = "${module.remote_state.lock_table_name}"
      }
    }
  EOT
}
