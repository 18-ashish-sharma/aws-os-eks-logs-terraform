# module/eks-cluster

EKS cluster (terraform-aws-modules/eks v21) with one Graviton managed node group, EKS add-ons, a VPC CNI IRSA role and admin access entries. Named `<cluster_name>-<env>`.

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |

### Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| eks | terraform-aws-modules/eks/aws | 21.29.0 |
| vpc\_cni\_irsa | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | 6.8.2 |

### Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| cluster\_name | Base name of the EKS cluster. The cluster is named <cluster\_name>-<env>. | `string` | n/a | yes |
| env | Environment name (e.g. staging, prod). Appended to the cluster name. | `string` | n/a | yes |
| private\_subnets | Private subnet IDs for the control-plane ENIs and the worker nodes. | `list(string)` | n/a | yes |
| vpc\_id | ID of the VPC the cluster runs in. | `string` | n/a | yes |
| cluster\_admin\_role\_arns | IAM role ARNs granted cluster-admin through EKS access entries (e.g. an SSO admin role). The identity that runs Terraform is always admin. | `list(string)` | `[]` | no |
| desired\_size | Desired number of nodes at creation. Ignored by the module afterwards so an autoscaler can own it. | `number` | `2` | no |
| eks\_cloudwatch\_log\_group\_retention\_in\_days | Retention, in days, for the EKS control-plane log group. | `number` | `90` | no |
| eks\_most\_recent\_add\_on | Track the most recent version of each EKS add-on. Leave false to keep add-on upgrades deliberate. | `bool` | `false` | no |
| enabled\_log\_types | EKS control-plane log types sent to CloudWatch. | `list(string)` | <pre>[<br/>  "api",<br/>  "audit",<br/>  "authenticator"<br/>]</pre> | no |
| endpoint\_public\_access\_cidrs | CIDR blocks allowed to reach the public Kubernetes API endpoint. Narrow this to office/VPN/CI ranges. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| instance\_types | Instance types for the node group (ARM/Graviton, to match the AL2023 ARM AMI). Several types improve Spot availability. | `list(string)` | <pre>[<br/>  "t4g.large"<br/>]</pre> | no |
| kubernetes\_version | EKS Kubernetes version. Pick one in standard support; extended support is billed at a higher hourly rate. | `string` | `"1.34"` | no |
| max\_size | Maximum number of nodes. | `number` | `3` | no |
| min\_size | Minimum number of nodes. | `number` | `2` | no |
| node\_disk\_size | Root EBS volume size for each node, in GiB. | `number` | `50` | no |
| nodegroup\_name | Name of the managed node group. | `string` | `"nodegroup1"` | no |
| tags | Extra tags applied to every resource in this module. | `map(string)` | `{}` | no |
| use\_spot\_instances | If true, the node group uses Spot capacity. | `bool` | `true` | no |

### Outputs

| Name | Description |
| ---- | ----------- |
| cluster\_arn | ARN of the EKS cluster. |
| cluster\_certificate\_authority\_data | Base64-encoded CA certificate of the cluster. |
| cluster\_endpoint | Endpoint of the Kubernetes API server. |
| cluster\_name | Name of the EKS cluster. |
| cluster\_oidc\_issuer\_url | OIDC issuer URL of the cluster. |
| node\_security\_group\_id | Security group ID attached to the worker nodes. |
| oidc\_provider | OIDC issuer without the https:// prefix; used as the condition key prefix in IRSA trust policies. |
| oidc\_provider\_arn | ARN of the IAM OIDC provider; the federated principal in IRSA trust policies. |
<!-- END_TF_DOCS -->
