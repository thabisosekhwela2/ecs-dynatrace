# Context outputs from infrastructure module (via labels module)
output "id" {
  description = "Disambiguated ID"
  value       = module.infrastructure.id
}

output "name" {
  description = "Normalized name"
  value       = module.infrastructure.name
}

output "namespace" {
  description = "Normalized namespace"
  value       = module.infrastructure.namespace
}

output "environment" {
  description = "Normalized environment"
  value       = module.infrastructure.environment
}

output "stage" {
  description = "Normalized stage"
  value       = module.infrastructure.stage
}

output "tags" {
  description = "Normalized Tag map"
  value       = module.infrastructure.tags
}

# Service Catalog outputs
output "portfolio_id" {
  description = "ID of the Service Catalog portfolio"
  value       = module.infrastructure.portfolio_id
}

output "portfolio_arn" {
  description = "ARN of the Service Catalog portfolio"
  value       = module.infrastructure.portfolio_arn
}

output "product_id" {
  description = "ID of the Service Catalog product"
  value       = module.infrastructure.product_id
}

output "product_arn" {
  description = "ARN of the Service Catalog product"
  value       = module.infrastructure.product_arn
}

output "service_catalog_role_arn" {
  description = "ARN of the Service Catalog IAM role"
  value       = module.infrastructure.service_catalog_role_arn
}

output "service_catalog_role_name" {
  description = "Name of the Service Catalog IAM role"
  value       = module.infrastructure.service_catalog_role_name
}

# Service Catalog Provisioned Product outputs
output "provisioned_product_id" {
  description = "ID of the Service Catalog provisioned product"
  value       = module.infrastructure.provisioned_product_id
}

output "provisioned_product_arn" {
  description = "ARN of the Service Catalog provisioned product"
  value       = module.infrastructure.provisioned_product_arn
}

output "provisioned_product_outputs" {
  description = "Outputs from the Service Catalog provisioned product"
  value       = module.infrastructure.provisioned_product_outputs
}

# EC2 Instance Management outputs
output "ec2_iam_role_arn" {
  description = "ARN of the IAM role created for EC2 instance"
  value       = module.infrastructure.ec2_iam_role_arn
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role created for EC2 instance"
  value       = module.infrastructure.ec2_iam_role_name
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile created for EC2 instance"
  value       = module.infrastructure.ec2_instance_profile_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile created for EC2 instance"
  value       = module.infrastructure.ec2_instance_profile_name
}

# Service Catalog Usage Information
output "service_catalog_usage" {
  description = "Instructions for using the Service Catalog"
  value = {
    portfolio_name = module.infrastructure.name
    product_name   = "${module.infrastructure.name}-product"
    region         = "af-south-1"
    console_url    = "https://af-south-1.console.aws.amazon.com/servicecatalog/home?region=af-south-1#/portfolios"
    instructions   = "Use the AWS Console or AWS CLI to provision EC2 instances through this Service Catalog portfolio. The IAM role and instance profile are created by Terraform and can be manually attached to the provisioned EC2 instance."
  }
} 