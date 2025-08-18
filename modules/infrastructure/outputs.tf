# Context outputs (from labels module)
output "id" {
  description = "Disambiguated ID"
  value       = module.labels.id
}

output "name" {
  description = "Normalized name"
  value       = module.labels.name
}

output "namespace" {
  description = "Normalized namespace"
  value       = module.labels.namespace
}

output "environment" {
  description = "Normalized environment"
  value       = module.labels.environment
}

output "stage" {
  description = "Normalized stage"
  value       = module.labels.stage
}

output "tags" {
  description = "Normalized Tag map"
  value       = module.labels.tags
}

# Service Catalog outputs
output "portfolio_id" {
  description = "ID of the Service Catalog portfolio"
  value       = aws_servicecatalog_portfolio.main.id
}

output "portfolio_arn" {
  description = "ARN of the Service Catalog portfolio"
  value       = aws_servicecatalog_portfolio.main.arn
}

output "product_id" {
  description = "ID of the Service Catalog product"
  value       = aws_servicecatalog_product.amazon_linux_3.id
}

output "product_arn" {
  description = "ARN of the Service Catalog product"
  value       = aws_servicecatalog_product.amazon_linux_3.arn
}

output "service_catalog_role_arn" {
  description = "ARN of the Service Catalog IAM role"
  value       = aws_iam_role.service_catalog.arn
}

output "service_catalog_role_name" {
  description = "Name of the Service Catalog IAM role"
  value       = aws_iam_role.service_catalog.name
}

# Service Catalog Provisioned Product outputs
output "provisioned_product_id" {
  description = "ID of the Service Catalog provisioned product"
  value       = var.provision_ec2_instance ? aws_servicecatalog_provisioned_product.ec2_instance[0].id : null
}

output "provisioned_product_arn" {
  description = "ARN of the Service Catalog provisioned product"
  value       = var.provision_ec2_instance ? aws_servicecatalog_provisioned_product.ec2_instance[0].arn : null
}

output "provisioned_product_outputs" {
  description = "Outputs from the Service Catalog provisioned product"
  value       = var.provision_ec2_instance ? aws_servicecatalog_provisioned_product.ec2_instance[0].outputs : null
}

# EC2 Instance Management outputs
output "ec2_iam_role_arn" {
  description = "ARN of the IAM role created for EC2 instance"
  value       = var.attach_iam_role ? aws_iam_role.ec2[0].arn : null
}

output "ec2_iam_role_name" {
  description = "Name of the IAM role created for EC2 instance"
  value       = var.attach_iam_role ? aws_iam_role.ec2[0].name : null
}

output "ec2_instance_profile_arn" {
  description = "ARN of the IAM instance profile created for EC2 instance"
  value       = var.attach_iam_role ? aws_iam_instance_profile.ec2[0].arn : null
}

output "ec2_instance_profile_name" {
  description = "Name of the IAM instance profile created for EC2 instance"
  value       = var.attach_iam_role ? aws_iam_instance_profile.ec2[0].name : null
} 