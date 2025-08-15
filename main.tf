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

# Local variables
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

# Service Catalog Module
module "service_catalog" {
  source = "./modules/service-catalog"

  portfolio_name        = var.portfolio_name
  portfolio_description = var.portfolio_description
  provider_name         = var.provider_name
  product_name          = var.product_name
  product_owner         = var.product_owner
  product_description   = var.product_description
  product_distributor   = var.product_distributor
  support_description   = var.support_description
  support_email         = var.support_email
  support_url           = var.support_url
  template_url          = var.template_url
  principal_arn         = var.principal_arn
  tags                  = local.common_tags
}

# EC2 Instance Module
module "ec2_instance" {
  source = "./modules/ec2-instance"

  instance_name         = var.instance_name
  instance_type         = var.instance_type
  ami_id                = var.ami_id
  key_name              = var.key_name
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  ssh_cidr_blocks       = var.ssh_cidr_blocks
  dynatrace_cidr_blocks = var.dynatrace_cidr_blocks
  root_volume_size      = var.root_volume_size
  root_volume_type      = var.root_volume_type
  environment           = var.environment
  tags                  = local.common_tags

  depends_on = [module.service_catalog]
}

# SSM Automation Module for Dynatrace ActiveGate
module "ssm_automation" {
  source = "./modules/ssm-automation"

  instance_name              = var.instance_name
  instance_id                = module.ec2_instance.instance_id
  dynatrace_environment_url  = var.dynatrace_environment_url
  dynatrace_token            = var.dynatrace_token
  activegate_version         = var.activegate_version
  tags                       = local.common_tags

  depends_on = [module.ec2_instance]
}

# Wait for instance to be ready and SSM agent to be available
resource "null_resource" "wait_for_instance" {
  depends_on = [module.ec2_instance]

  provisioner "local-exec" {
    command = "sleep 60"  # Wait 60 seconds for instance to be fully ready
  }
}

# Automatic SSM Command to trigger Dynatrace installation
resource "null_resource" "auto_install_dynatrace" {
  depends_on = [
    null_resource.wait_for_instance,
    module.ssm_automation
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for SSM agent to be ready..."
      sleep 30
      
      echo "Triggering Dynatrace ActiveGate installation..."
      aws ssm send-command \
        --instance-ids ${module.ec2_instance.instance_id} \
        --document-name "${module.ssm_automation.ssm_document_name}" \
        --parameters '{"dynatraceEnvironmentUrl":["${var.dynatrace_environment_url}"],"dynatraceToken":["${var.dynatrace_token}"],"activegateVersion":["${var.activegate_version}"]}' \
        --region af-south-1
      
      echo "Dynatrace ActiveGate installation triggered successfully!"
    EOT
  }

  triggers = {
    instance_id = module.ec2_instance.instance_id
    document_name = module.ssm_automation.ssm_document_name
    timestamp = timestamp()
  }
} 