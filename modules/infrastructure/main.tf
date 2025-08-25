terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
# DATA SOURCES
# =============================================================================

data "aws_caller_identity" "current" {}

# =============================================================================
# LOCALS
# =============================================================================

locals {
  account_id = data.aws_caller_identity.current.account_id
  
  # Retrieving instance id from provisioned product outputs
  ec2_instance_id = var.provision_ec2_instance && var.create_service_catalog ? (
    try(
      [for o in aws_servicecatalog_provisioned_product.ec2_instance[0].outputs : o.value if o.key == "InstanceId"][0],
      null
    )
  ) : null
  
  # Dynamic parameter handling
  dynamic_parameters = {
    for item in var.provisioning_parameters : item.key => item.value
  }
  
  # Static parameters that are always included
  static_parameters = var.create_iam_instance_profile ? {
    IamInstanceRole = aws_iam_instance_profile.ec2[0].name
    InstanceName    = module.labels.id # Limitation of 15 characters
  } : {
    InstanceName = module.labels.id
  }
  
  # Merge dynamic and static parameters
  all_parameters = merge(local.dynamic_parameters, local.static_parameters)
  
  # Permissions boundary for IAM roles
  permissions_boundary = var.use_permissions_boundary ? "arn:aws:iam::${local.account_id}:policy/BoundedPermissionsPolicy" : null
  
  # Filter out duplicate tags to avoid AWS IAM errors
  # AWS treats tag keys as case-insensitive, so we need to ensure uniqueness
  filtered_tags = {
    for key, value in module.labels.tags : key => value
    if !contains(["environment"], lower(key)) || key == "environment"
  }
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
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]

  tags = local.filtered_tags
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

# =============================================================================
# EC2 IAM INSTANCE PROFILE
# =============================================================================

# Custom Role for EC2 Instance
resource "aws_iam_role" "ec2" {
  count = var.create_iam_instance_profile ? 1 : 0
  
  name = join(module.labels.delimiter, ["Bounded", module.labels.id])
  description = var.iam_role_description
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  permissions_boundary = local.permissions_boundary
  tags = local.filtered_tags
}

# SSM Policy Attachment for EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  count = var.create_iam_instance_profile ? 1 : 0
  
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Additional policy attachments for EC2 role
resource "aws_iam_role_policy_attachment" "ec2_additional_policies" {
  for_each = var.create_iam_instance_profile ? toset(var.ec2_role_additional_policies) : toset([])
  
  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_instance_profile ? 1 : 0
  
  name = module.labels.id
  role = aws_iam_role.ec2[0].name
  tags = local.filtered_tags
}

# =============================================================================
# SERVICE CATALOG PORTFOLIO
# =============================================================================

resource "aws_servicecatalog_portfolio" "main" {
  count = var.create_service_catalog ? 1 : 0
  
  name          = "${module.labels.name}-portfolio"
  description   = var.portfolio_description
  provider_name = var.provider_name

  tags = module.labels.tags
}

# =============================================================================
# SERVICE CATALOG PRODUCT
# =============================================================================

resource "aws_servicecatalog_product" "amazon_linux_3" {
  count = var.create_service_catalog ? 1 : 0
  
  name        = "${module.labels.name}-product"
  owner       = var.product_owner
  description = var.product_description
  distributor = var.product_distributor
  support_description = var.support_description
  support_email       = var.support_email
  support_url         = var.support_url
  type                = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    template_url = var.template_url
    name         = "v2.1"
    type         = "CLOUD_FORMATION_TEMPLATE"
  }

  tags = module.labels.tags
}

# =============================================================================
# SERVICE CATALOG ASSOCIATIONS
# =============================================================================

resource "aws_servicecatalog_product_portfolio_association" "main" {
  count = var.create_service_catalog ? 1 : 0
  
  portfolio_id = aws_servicecatalog_portfolio.main[0].id
  product_id   = aws_servicecatalog_product.amazon_linux_3[0].id
}

resource "aws_servicecatalog_principal_portfolio_association" "main" {
  count = var.create_service_catalog ? 1 : 0
  
  portfolio_id = aws_servicecatalog_portfolio.main[0].id
  principal_arn = var.principal_arn
  principal_type = "IAM"
}

# =============================================================================
# SERVICE CATALOG PROVISIONING (EC2 INSTANCE)
# =============================================================================

# Service Catalog Provisioned Product (creates the EC2 instance)
resource "aws_servicecatalog_provisioned_product" "ec2_instance" {
  count = var.provision_ec2_instance && var.create_service_catalog ? 1 : 0
  
  name                   = module.labels.id
  product_id             = aws_servicecatalog_product.amazon_linux_3[0].id
  provisioning_artifact_name = "v2.1"
  
  dynamic "provisioning_parameters" {
    for_each = local.all_parameters
    
    content {
      key   = provisioning_parameters.key
      value = provisioning_parameters.value
    }
  }

  tags = local.filtered_tags
  depends_on = [aws_iam_instance_profile.ec2]
} 

# =============================================================================
# SECURITY GROUP CREATION (NATIVE TERRAFORM)
# =============================================================================

# Get EC2 instance details after provisioning
data "aws_instance" "provisioned_ec2" {
  count = var.create_service_catalog && var.provision_ec2_instance ? 1 : 0
  
  instance_id = local.ec2_instance_id
  
  depends_on = [aws_servicecatalog_provisioned_product.ec2_instance]
}

# Create security group using native Terraform
resource "aws_security_group" "ec2_instance" {
  count = var.create_service_catalog && var.provision_ec2_instance ? 1 : 0
  
  name        = "${module.labels.name}-sg"
  description = "Security group for EC2 instance created by Service Catalog"
  vpc_id      = var.vpc_id

  # Parse and create ingress rules from JSON
  dynamic "ingress" {
    for_each = jsondecode(var.security_group_ingress_rules)
    content {
      description = ingress.value.Description
      from_port   = ingress.value.FromPort
      to_port     = ingress.value.ToPort
      protocol    = ingress.value.IpProtocol
      cidr_blocks = [ingress.value.CidrIp]
    }
  }

  # Parse and create egress rules from JSON
  dynamic "egress" {
    for_each = jsondecode(var.security_group_egress_rules)
    content {
      description = egress.value.Description
      from_port   = try(egress.value.FromPort, 0)
      to_port     = try(egress.value.ToPort, 0)
      protocol    = egress.value.IpProtocol
      cidr_blocks = [egress.value.CidrIp]
    }
  }

  tags = merge(local.filtered_tags, {
    Name = "${module.labels.name}-sg"
  })
}

# Get EC2 instance network interface
data "aws_network_interface" "ec2_eni" {
  count = var.create_service_catalog && var.provision_ec2_instance ? 1 : 0
  
  id = data.aws_instance.provisioned_ec2[0].network_interface_id
  
  depends_on = [data.aws_instance.provisioned_ec2]
}

# Attach security group to EC2 instance
resource "aws_network_interface_sg_attachment" "ec2_sg_attachment" {
  count = var.create_service_catalog && var.provision_ec2_instance ? 1 : 0
  
  security_group_id    = aws_security_group.ec2_instance[0].id
  network_interface_id = data.aws_network_interface.ec2_eni[0].id
  
  depends_on = [data.aws_network_interface.ec2_eni, aws_security_group.ec2_instance]
} 