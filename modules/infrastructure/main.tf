terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.0"
    }
  }
}

# =============================================================================
# LABELS
# =============================================================================

module "labels" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  enabled     = var.enabled
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  tags        = var.tags

  context = var.context
}

# =============================================================================
# SERVICE CATALOG INFRASTRUCTURE
# =============================================================================

# IAM Role for Service Catalog operations
resource "aws_iam_role" "service_catalog" {
  count = var.create_service_catalog ? 1 : 0
  
  name = "${module.labels.name}-service-catalog-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "servicecatalog.amazonaws.com"
        }
      }
    ]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ]
  
  tags = module.labels.tags
}

# IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "service_catalog_cloudformation" {
  count = var.create_service_catalog ? 1 : 0
  
  role       = aws_iam_role.service_catalog[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "service_catalog_ec2" {
  count = var.create_service_catalog ? 1 : 0
  
  role       = aws_iam_role.service_catalog[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "service_catalog_ssm" {
  count = var.create_service_catalog ? 1 : 0
  
  role       = aws_iam_role.service_catalog[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "main" {
  count = var.create_service_catalog ? 1 : 0
  
  name          = "${module.labels.name}-portfolio"
  description   = var.portfolio_description
  provider_name = var.provider_name
}

# Service Catalog Product
resource "aws_servicecatalog_product" "amazon_linux_3" {
  count = var.create_service_catalog ? 1 : 0
  
  name                = "${module.labels.name}-product"
  description         = var.product_description
  owner               = var.product_owner
  distributor         = var.product_distributor
  support_description = var.support_description
  support_email       = var.support_email
  support_url         = var.support_url
  type                = "CLOUD_FORMATION_TEMPLATE"
  
  provisioning_artifact_parameters {
    name                        = "v1.8"
    description                 = "Amazon Linux 3 EC2 Instance - With IAM role support and correct AMI"
    template_url                = var.template_url
    type                        = "CLOUD_FORMATION_TEMPLATE"
    disable_template_validation = false
  }
  
  tags = module.labels.tags
}

# Product Portfolio Association
resource "aws_servicecatalog_product_portfolio_association" "main" {
  count = var.create_service_catalog ? 1 : 0
  
  portfolio_id = aws_servicecatalog_portfolio.main[0].id
  product_id   = aws_servicecatalog_product.amazon_linux_3[0].id
}

# Principal Portfolio Association
resource "aws_servicecatalog_principal_portfolio_association" "main" {
  count = var.create_service_catalog && var.principal_arn != "" ? 1 : 0
  
  portfolio_id    = aws_servicecatalog_portfolio.main[0].id
  principal_arn   = var.principal_arn
  principal_type  = "IAM"
}

# =============================================================================
# SSM AUTOMATION DOCUMENT
# =============================================================================

# SSM Document for Security Group Management
resource "aws_ssm_document" "security_group_manager" {
  count = var.create_service_catalog ? 1 : 0
  
  name            = "${module.labels.name}-security-group-manager"
  document_type   = "Automation"
  document_format = "YAML"
  
  content = <<DOC
---
schemaVersion: '0.3'
description: 'Create and configure security groups for EC2 instances'

parameters:
  InstanceId:
    type: String
    description: 'EC2 Instance ID'
  SecurityGroupName:
    type: String
    description: 'Name for the security group'
  VpcId:
    type: String
    description: 'VPC ID where security group will be created'
  Description:
    type: String
    description: 'Description for the security group'
    default: 'Security group created by Service Catalog'
  IngressRules:
    type: String
    description: 'JSON array of ingress rules'
    default: '[]'
  EgressRules:
    type: String
    description: 'JSON array of egress rules'
    default: '[{"Description":"All outbound traffic","FromPort":0,"ToPort":0,"Protocol":"-1","CidrBlocks":["0.0.0.0/0"]}]'

mainSteps:
- name: CreateSecurityGroup
  action: 'aws:executeAwsApi'
  inputs:
    Service: ec2
    Api: CreateSecurityGroup
    GroupName: '{{ SecurityGroupName }}'
    Description: '{{ Description }}'
    VpcId: '{{ VpcId }}'
  outputs:
    - Name: SecurityGroupId
      Selector: '$.GroupId'
      Type: String

- name: ConfigureIngressRules
  action: 'aws:executeAwsApi'
  inputs:
    Service: ec2
    Api: AuthorizeSecurityGroupIngress
    GroupId: '{{ CreateSecurityGroup.SecurityGroupId }}'
    IpPermissions: '{{ IngressRules }}'
  isEnd: false
  nextStep: ConfigureEgressRules

- name: ConfigureEgressRules
  action: 'aws:executeAwsApi'
  inputs:
    Service: ec2
    Api: AuthorizeSecurityGroupEgress
    GroupId: '{{ CreateSecurityGroup.SecurityGroupId }}'
    IpPermissions: '{{ EgressRules }}'
  isEnd: false
  nextStep: AttachToInstance

- name: AttachToInstance
  action: 'aws:executeAwsApi'
  inputs:
    Service: ec2
    Api: ModifyInstanceAttribute
    InstanceId: '{{ InstanceId }}'
    Groups:
      - '{{ CreateSecurityGroup.SecurityGroupId }}'
  isEnd: true
DOC

  tags = module.labels.tags
}

# =============================================================================
# SERVICE ACTION
# =============================================================================

# Service Action for Security Group Management
resource "aws_servicecatalog_service_action" "security_group_manager" {
  count = var.create_service_catalog ? 1 : 0
  
  name        = "${module.labels.name}-security-group-manager"
  description = "Service action to create and manage security groups for EC2 instances"
  definition {
    name = aws_ssm_document.security_group_manager[0].name
    version = aws_ssm_document.security_group_manager[0].latest_version
    assume_role = aws_iam_role.service_catalog[0].arn
  }
}

# =============================================================================
# SERVICE ACTION ASSOCIATION
# =============================================================================

# Get the latest provisioning artifact
data "aws_servicecatalog_provisioning_artifacts" "main" {
  count = var.create_service_catalog ? 1 : 0
  product_id = aws_servicecatalog_product.amazon_linux_3[0].id
}

locals {
  # Get the latest provisioning artifact ID
  provisioning_artifact_id = var.create_service_catalog ? (
    try(
      [for artifact in data.aws_servicecatalog_provisioning_artifacts.main[0].provisioning_artifact_details : artifact.id if artifact.active][0],
      null
    )
  ) : null
}

# Service Action Association using AWSCC provider
resource "awscc_servicecatalog_service_action_association" "security_group_manager" {
  count = var.create_service_catalog ? 1 : 0
  
  product_id              = aws_servicecatalog_product.amazon_linux_3[0].id
  provisioning_artifact_id = local.provisioning_artifact_id
  service_action_id       = aws_servicecatalog_service_action.security_group_manager[0].id
}

# =============================================================================
# SERVICE CATALOG PROVISIONING (EC2 INSTANCE)
# =============================================================================

# Service Catalog Provisioned Product (creates the EC2 instance)
resource "aws_servicecatalog_provisioned_product" "ec2_instance" {
  count = var.provision_ec2_instance && var.create_service_catalog ? 1 : 0
  
  name                   = "${module.labels.name}-instance"
  product_id             = aws_servicecatalog_product.amazon_linux_3[0].id
  provisioning_artifact_name = "v1.8"
  
  dynamic "provisioning_parameters" {
    for_each = [
      {
        key   = "InstanceType"
        value = var.instance_type
      },
      {
        key   = "InstanceName"
        value = module.labels.name
      },
      {
        key   = "Environment"
        value = var.environment
      },
      {
        key   = "KeyPairName"
        value = var.key_pair_name
      },
      {
        key   = "VpcId"
        value = var.vpc_id
      },
      {
        key   = "SubnetId"
        value = var.subnet_id
      }
    ]
    
    content {
      key   = provisioning_parameters.value.key
      value = provisioning_parameters.value.value
    }
  }

  tags = module.labels.tags
} 