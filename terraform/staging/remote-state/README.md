# terraform/staging/remote-state

Bootstrap stack for the staging backend. Runs with local state; see the main README for the order of operations.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| remote\_state | ../../../module/remote-state | n/a |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket\_name | Project slug for the bucket name: terraform-<bucket\_name>-<env>-state. Must make the bucket name globally unique. | `string` | n/a | yes |
| env | Environment name. | `string` | `"staging"` | no |
| project | Value for the Project tag. | `string` | `"eks-logs"` | no |
| region | AWS region for the state bucket and lock table. | `string` | `"ap-south-1"` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| backend\_config | Backend block to paste into base-infra/backend.tf. |
| lock\_table | DynamoDB table for state locking. |
| state\_bucket | S3 bucket for Terraform state. |
<!-- END_TF_DOCS -->
