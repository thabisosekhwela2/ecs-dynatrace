# Labels Module for standardized naming and tagging
module "labels" {
  source      = "../labels"
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  tags        = var.tags
  context     = var.context
}

# =============================================================================
# SERVICE CATALOG RESOURCES
# =============================================================================

# Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "main" {
  name          = "${module.labels.name}-portfolio"
  description   = var.portfolio_description
  provider_name = var.provider_name
}

# Service Catalog Product
resource "aws_servicecatalog_product" "amazon_linux_3" {
  name        = "${module.labels.name}-product"
  owner       = var.product_owner
  description = var.product_description
  distributor = var.product_distributor
  support_description = var.support_description
  support_email = var.support_email
  support_url = var.support_url
  type        = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    template_url = var.template_url
    name         = "v1.4"
    type         = "CLOUD_FORMATION_TEMPLATE"
    description  = "Amazon Linux 3 EC2 Instance - IAM role attached after deployment"
  }

  tags = module.labels.tags
}

# Associate Product with Portfolio
resource "aws_servicecatalog_product_portfolio_association" "main" {
  portfolio_id = aws_servicecatalog_portfolio.main.id
  product_id   = aws_servicecatalog_product.amazon_linux_3.id
}

# IAM Role for Service Catalog
resource "aws_iam_role" "service_catalog" {
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

  tags = module.labels.tags
}

# Attach policies to Service Catalog role
resource "aws_iam_role_policy_attachment" "service_catalog_cloudformation" {
  role       = aws_iam_role.service_catalog.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "service_catalog_ec2" {
  role       = aws_iam_role.service_catalog.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "service_catalog_ssm" {
  role       = aws_iam_role.service_catalog.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Service Catalog Principal Association
resource "aws_servicecatalog_principal_portfolio_association" "main" {
  portfolio_id  = aws_servicecatalog_portfolio.main.id
  principal_arn = var.principal_arn
}

# =============================================================================
# SERVICE CATALOG PROVISIONING (EC2 INSTANCE FIRST)
# =============================================================================

# Service Catalog Provisioned Product (creates the EC2 instance WITHOUT IAM role)
resource "aws_servicecatalog_provisioned_product" "ec2_instance" {
  count = var.provision_ec2_instance ? 1 : 0
  
  name                   = "${module.labels.name}-instance"
  product_id             = aws_servicecatalog_product.amazon_linux_3.id
  provisioning_artifact_name = "v1.4"
  
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
        value = ""
      },
      {
        key   = "VpcId"
        value = ""
      },
      {
        key   = "SubnetId"
        value = ""
      },
      {
        key   = "IamInstanceProfileName"
        value = ""  # No IAM role during initial creation
      }
    ]
    
    content {
      key   = provisioning_parameters.value.key
      value = provisioning_parameters.value.value
    }
  }

  tags = module.labels.tags
}

# =============================================================================
# IAM ROLE CREATION AFTER EC2 DEPLOYMENT
# =============================================================================

# IAM Role for EC2 instance (created when EC2 provisioning and IAM attachment are enabled)
resource "aws_iam_role" "ec2" {
  count = var.provision_ec2_instance && var.attach_iam_role ? 1 : 0
  
  name = "${module.labels.name}-ec2-role"

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

  tags = module.labels.tags
  
  # Wait for Service Catalog to complete and provide instance ID
  depends_on = [aws_servicecatalog_provisioned_product.ec2_instance]
}

# IAM Instance Profile (created when EC2 provisioning and IAM attachment are enabled)
resource "aws_iam_instance_profile" "ec2" {
  count = var.provision_ec2_instance && var.attach_iam_role ? 1 : 0
  
  name = "${module.labels.name}-instance-profile"
  role = aws_iam_role.ec2[0].name
  
  depends_on = [aws_iam_role.ec2]
}

# Attach SSM policy to EC2 role
# resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
#   count = var.provision_ec2_instance && var.attach_iam_role ? 1 : 0
#   
#   role       = aws_iam_role.ec2[0].name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   
#   depends_on = [aws_iam_role.ec2]
# }

# Attach CloudWatch policy to EC2 role
# resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
#   count = var.provision_ec2_instance && var.attach_iam_role ? 1 : 0
#   
#   role       = aws_iam_role.ec2[0].name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#   
#   depends_on = [aws_iam_role.ec2]
# }

# =============================================================================
# IAM ROLE ATTACHMENT USING CLOUDFORMATION OUTPUTS
# =============================================================================

# Extract EC2 instance ID from Service Catalog outputs
locals {
  ec2_instance_id = var.provision_ec2_instance && var.attach_iam_role ? (
    try(
      [for output in aws_servicecatalog_provisioned_product.ec2_instance[0].outputs : output.value if output.key == "InstanceId"][0],
      null
    )
  ) : null
}



# Use AWS CLI to attach IAM role to EC2 instance (simplified approach)
resource "null_resource" "attach_iam_role_to_ec2" {
  count = var.provision_ec2_instance && var.attach_iam_role ? 1 : 0
  
  triggers = {
    instance_id = local.ec2_instance_id
    instance_profile_name = aws_iam_instance_profile.ec2[0].name
  }
  
  provisioner "local-exec" {
    command = "aws ec2 associate-iam-instance-profile --instance-id ${local.ec2_instance_id} --iam-instance-profile Name=${aws_iam_instance_profile.ec2[0].name}"
  }
  
  depends_on = [
    aws_iam_instance_profile.ec2,
    aws_servicecatalog_provisioned_product.ec2_instance
  ]
}

# Apply tags to EC2 instance using Terraform
resource "aws_ec2_tag" "ec2_tags" {
  for_each = var.provision_ec2_instance && var.attach_iam_role ? module.labels.tags : {}
  
  resource_id = local.ec2_instance_id
  key         = each.key
  value       = each.value
  
  depends_on = [aws_servicecatalog_provisioned_product.ec2_instance]
} 