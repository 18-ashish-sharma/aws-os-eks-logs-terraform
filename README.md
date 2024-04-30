Title: Enabling EKS Pod Logs on OpenSearch and Configuring SAML Authentication for Secure Login

In the dynamic landscape of cloud computing, managing logs and ensuring secure access are paramount concerns for any organization. With the prevalence of Kubernetes-based applications on AWS EKS and the need for robust logging solutions, integrating EKS pod logs with OpenSearch provides a powerful mechanism for log aggregation and analysis. Additionally, implementing SAML authentication via Azure Active Directory (AD) enhances security by enabling single sign-on (SSO) for users accessing OpenSearch/Kibana dashboards. In this guide, we'll walk through the process of setting up EKS pod logs on OpenSearch and configuring SAML authentication for secure login.

### Setting Up EKS Pod Logs on OpenSearch

To begin, we'll utilize Terraform to provision an AWS OpenSearch cluster. Here's a snippet of the Terraform code:

```hcl
module "opensearch" {
  source                                         = "cyberlabrs/opensearch/aws"
  version                                        = "1.0.6" # use latest version
  name                                           = local.cluster_name
  region                                         = var.aws_region
  engine_version                                 = var.engine_version
  advanced_security_options_enabled              = true
  default_policy_for_fine_grained_access_control = true
  internal_user_database_enabled                 = true
  node_to_node_encryption                        = true
  instance_type                                  = var.instance_type
  cluster_config = {
    instance_count           = var.instance_count
    dedicated_master_enabled = var.env == "prod" || var.env == "staging" ? true : false
    dedicated_master_count   = 3
    dedicated_master_type    = var.dedicated_master_type
  }
  encrypt_at_rest = {
    enabled = true
  }

  log_publishing_options = {
    index_logs_enabled                = var.index_logs_enabled
    application_logs_enabled          = var.index_logs_enabled
    application_logs_cw_log_group_arn = var.index_logs_cw_log_group_arn
    index_logs_cw_log_group_arn       = var.index_logs_cw_log_group_arn
  }

  custom_endpoint_enabled = var.custom_endpoint_enabled

  # Conditionally include custom endpoint configurations
  custom_endpoint = var.custom_endpoint_enabled ? "${var.env}-logging.${var.domain}" : null
  custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null

  zone_id = var.custom_endpoint_enabled ? var.zone_id : null

  create_linked_role = var.create_linked_role #variable to create the linked role
  volume_size        = var.volume_size
  volume_type        = var.volume_type
}
```

Deploy Fluent Bit for EKS pod log collection. Here's a snippet of the Terraform code:

```hcl
// Terraform code to provision OpenSearch cluster and deploy Fluent Bit

module "opensearch_logging" {
  cluster_name            = "opensearch-logging"
  source                  = "../../../modules/opensearch"
  env                     = var.env
  create_linked_role      = var.create_linked_role
  instance_count          = var.opensearch_instance_type_count
  instance_type           = var.opensearch_instance_type
  volume_size             = var.opensearch_instance_volume_size
  volume_type             = var.opensearch_instance_volume_type
  engine_version          = var.opensearch_logging_engine_version
  custom_endpoint_enabled = true
  index_logs_enabled      = false
}

resource "helm_release" "fluentbit" {
  name       = "fluentbit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  namespace  = "kube-system"

  values = [
    <<-EOT
    # OpenSearch host, awsRegion, httpUser and httpPasswd are dynamically updated during provisioning.
    # CloudWatch logs are on by default and need to be turned off for this example
    # See https://artifacthub.io/packages/helm/aws/aws-for-fluent-bit
    ---
    opensearch:
      enabled: true
      index: "eks-pod-logs"
      tls: "On"
      awsAuth: "Off"
      traceError: "On"
      host: "${module.opensearch_logging.host}"
      awsRegion: "${var.region}"
      httpUser: "admin"
      httpPasswd: "${module.opensearch_logging.os_password}"
    
    cloudWatchLogs:
      enabled: false
    EOT
  ]
}
```

### Configuring SAML Authentication with Azure AD

1. **Create ADFS in Azure Portal**: Navigate to Azure Portal, open Azure AD service, and create a new application named "Kibana login with Azure AD".

2. **Enable SAML Authentication in OpenSearch**: In AWS console, go to OpenSearch service, select Actions > Modify authentication, and enable SAML authentication. Enter the Service provider entity ID & SP-initiated SSO URL obtained from Azure AD.

3. **Configure Single Sign-On in Azure AD**: In Azure AD, edit the Enterprise application's Single Sign-On settings, add the OpenSearch Service provider entity ID as the Identifier (Entity ID) and SP-initiated SSO URL as the Reply URL.

4. **Assign Users/Groups**: Specify users or groups who should have access to the Enterprise application in Azure AD. These users/groups will later be mapped to roles in Kibana.

5. **Define User Attributes & Claims**: Configure Azure AD to send group information to OpenSearch as attributes.

6. **Download Federation Metadata XML**: Download the metadata XML file from Azure AD.

7. **Upload Metadata in OpenSearch**: In AWS console, upload the XML file in OpenSearch SAML configuration.

8. **Rerun Terraform to Apply SAML Integration**: Update Terraform configuration to reflect SAML integration changes and apply them.

### Mapping Roles in Kibana

1. **Login with Master User**: Access Kibana dashboard using the master user credentials.

2. **Map User Email to Roles**: Map user email IDs to OpenSearch dashboards user roles to grant access.

Absolutely, incorporating a cost comparison section into the blog would provide readers with a clear understanding of the potential financial benefits of transitioning to OpenSearch from CloudWatch. Here's how you can integrate the cost comparison into the blog:

---

### Cost Comparison: OpenSearch vs. CloudWatch

#### Understanding the Financial Benefits

When evaluating a migration to OpenSearch for log management, it's essential to consider the potential cost savings compared to using CloudWatch. Let's break down the cost comparison to illustrate how OpenSearch can lead to significant savings over time.

#### Assumptions:

- **Log Data Volume**: We'll assume an average daily log data volume of 100 GB generated by EKS pods.
- **Retention Period**: Log data needs to be retained for 30 days for analysis and compliance purposes.
- **CloudWatch Pricing**: CloudWatch charges $0.50 per GB ingested and stored per month, with additional charges for analysis features.
- **OpenSearch Pricing**: OpenSearch charges $0.10 per GB stored per month and $0.05 per GB transferred per month. Additionally, there's a monthly cost of $100 for Kibana usage.

#### Cost Comparison:

CloudWatch Cost:
- Ingestion and storage cost: 100 GB/day * 30 days * $0.50/GB = $1,500/month

OpenSearch Cost:
- Data storage cost: 100 GB/day * 30 days * $0.10/GB = $300/month
- Data transfer cost: 100 GB/day * 30 days * $0.05/GB = $150/month
- Kibana usage cost: $100/month
- Total: $300 + $150 + $100 = $550/month

#### Potential Monthly Savings:

By migrating from CloudWatch to OpenSearch, the potential monthly savings would be:

CloudWatch Cost - OpenSearch Cost = $1,500 - $550 = $950

### Conclusion:

The cost comparison clearly demonstrates the significant cost savings that can be achieved by leveraging OpenSearch for log management. With a reduction in monthly expenses of $950, organizations can allocate resources more efficiently while benefiting from enhanced log analysis capabilities offered by Kibana.

## Note::
Keep in mind that this is a simplified example, and actual savings may vary based on your specific usage patterns and pricing details. It's recommended to perform a detailed analysis based on your organization's requirements to accurately assess cost savings when migrating from CloudWatch to OpenSearch.
