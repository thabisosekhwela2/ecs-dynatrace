# Configure AWS Provider for Cape Town region
provider "aws" {
  region = "af-south-1"  # Cape Town region
}

# Configure Terraform
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Infrastructure Module (Service Catalog + EC2 Management)
module "infrastructure" {
  source = "./modules/infrastructure"

  # Context variables
  enabled     = var.enabled
  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  context     = var.context

  # Service Catalog variables
  portfolio_description = var.portfolio_description
  provider_name         = var.provider_name
  product_owner         = var.product_owner
  product_description   = var.product_description
  product_distributor   = var.product_distributor
  support_description   = var.support_description
  support_email         = var.support_email
  support_url           = var.support_url
  template_url          = var.template_url
  principal_arn         = var.principal_arn

  # Service Catalog Provisioning variables
  provision_ec2_instance = var.provision_ec2_instance
  instance_type          = var.instance_type
  key_name               = var.key_name

  # EC2 Instance Management variables
  ec2_instance_id       = var.ec2_instance_id
  ec2_instance_name_tag = var.ec2_instance_name_tag
  attach_security_group = var.attach_security_group
  attach_iam_role       = var.attach_iam_role
  ssh_cidr_blocks       = var.ssh_cidr_blocks
  dynatrace_cidr_blocks = var.dynatrace_cidr_blocks

  tags = var.tags
} 