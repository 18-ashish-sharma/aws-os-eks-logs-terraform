# module/remote-state

S3 bucket (versioned, SSE-KMS, private, TLS-only, old versions expire) and DynamoDB lock table (on-demand, PITR) for Terraform state.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |

### Providers

| Name | Version |
| ---- | ------- |
| aws | 6.72.0 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_dynamodb_table.terraform_state_lock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.tls_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket\_name | Short project slug used to build the bucket and lock-table names: terraform-<bucket\_name>-<env>-state. S3 bucket names are global, so make it unique. | `string` | n/a | yes |
| env | Environment name (e.g. staging, prod). Part of every resource name. | `string` | n/a | yes |
| module\_name | Value for the Subproject tag: the root module whose state this bucket holds. | `string` | `"base-infra"` | no |
| noncurrent\_version\_retention\_days | Days to keep old (noncurrent) state file versions before S3 deletes them. | `number` | `90` | no |
| project | Value for the Project tag. | `string` | `"eks-logs"` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_arn | ARN of the state bucket. |
| bucket\_name | Name of the S3 bucket that stores Terraform state. |
| lock\_table\_name | Name of the DynamoDB table used for state locking. |
<!-- END_TF_DOCS -->
