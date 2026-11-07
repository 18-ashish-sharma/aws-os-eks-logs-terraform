# module/opensearch

Amazon OpenSearch Service domain with fine-grained access control, encryption at rest and in transit, CloudWatch application/audit logs, optional SAML for Dashboards and an optional custom endpoint. Named `<cluster_name>-<env>`.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |
| random | ~> 3.7 |

### Providers

| Name | Version |
| ---- | ------- |
| aws | 6.72.0 |
| random | 3.9.1 |

### Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_opensearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_opensearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_policy) | resource |
| [aws_opensearch_domain_saml_options.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_saml_options) | resource |
| [aws_route53_record.custom_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.log_publishing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| env | Environment name (e.g. staging, prod). Appended to the domain name. | `string` | n/a | yes |
| cluster\_name | Base name of the OpenSearch domain. The domain is named <cluster\_name>-<env>. | `string` | `"opensearch"` | no |
| custom\_endpoint | Optional custom hostname for the domain, e.g. logging.example.com. Requires custom\_endpoint\_certificate\_arn and zone\_id. | `string` | `null` | no |
| custom\_endpoint\_certificate\_arn | ACM certificate ARN covering custom\_endpoint. | `string` | `null` | no |
| dedicated\_master\_enabled | Run three dedicated master nodes. Recommended for staging/prod; adds cost. | `bool` | `false` | no |
| dedicated\_master\_type | Instance type for dedicated master nodes (used only when dedicated\_master\_enabled = true). | `string` | `"c6g.large.search"` | no |
| engine\_version | OpenSearch engine version, e.g. OpenSearch\_2.11. | `string` | `"OpenSearch_2.11"` | no |
| instance\_count | Number of data nodes. Use an even number > 1 to spread across two AZs. | `number` | `2` | no |
| instance\_type | Data node instance type. | `string` | `"t3.small.search"` | no |
| log\_retention\_days | Retention, in days, for the domain's application and audit log groups in CloudWatch. | `number` | `30` | no |
| master\_user\_name | Name of the internal master user (used for break-glass access and by Terraform to manage security roles). | `string` | `"admin"` | no |
| saml | SAML (e.g. Microsoft Entra ID) settings for OpenSearch Dashboards. Leave null to skip.<br/>idp\_entity\_id       - the IdP "Azure AD Identifier" / entity ID.<br/>idp\_metadata\_xml    - contents of the IdP federation metadata XML.<br/>master\_backend\_role - IdP group ID whose members become OpenSearch admins.<br/>roles\_key           - SAML attribute that carries the user's groups. | <pre>object({<br/>    idp_entity_id           = string<br/>    idp_metadata_xml        = string<br/>    master_backend_role     = string<br/>    roles_key               = optional(string, "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups")<br/>    session_timeout_minutes = optional(number, 60)<br/>  })</pre> | `null` | no |
| tags | Extra tags applied to every resource in this module. | `map(string)` | `{}` | no |
| volume\_size | EBS volume size per data node, in GiB. | `number` | `10` | no |
| volume\_type | EBS volume type for data nodes. | `string` | `"gp3"` | no |
| zone\_id | Route 53 hosted zone ID in which to create the custom\_endpoint CNAME. | `string` | `null` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| dashboard\_endpoint | OpenSearch Dashboards hostname and path (no scheme). |
| domain\_arn | ARN of the OpenSearch domain. Use <arn>/* in IAM policies. |
| domain\_name | Name of the OpenSearch domain. |
| endpoint | Domain endpoint hostname (no scheme), used by Fluent Bit and API clients. |
| master\_password | Internal master user password. Stored in state; read with `terraform output -raw`. |
| master\_username | Internal master user name. |
| saml\_acs\_url | SP-initiated SSO / Assertion Consumer Service URL to enter in the IdP as the Reply URL. |
| saml\_sp\_entity\_id | Service provider entity ID to enter in the IdP as the Identifier. |
<!-- END_TF_DOCS -->
