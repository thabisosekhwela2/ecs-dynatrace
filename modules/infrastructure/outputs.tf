# =============================================================================
# SERVICE CATALOG OUTPUTS
# =============================================================================

output "portfolio_id" {
  description = "ID of the Service Catalog portfolio"
  value       = var.create_service_catalog ? aws_servicecatalog_portfolio.main[0].id : null
}

output "portfolio_arn" {
  description = "ARN of the Service Catalog portfolio"
  value       = var.create_service_catalog ? aws_servicecatalog_portfolio.main[0].arn : null
}

output "product_id" {
  description = "ID of the Service Catalog product"
  value       = var.create_service_catalog ? aws_servicecatalog_product.amazon_linux_3[0].id : null
}

output "product_arn" {
  description = "ARN of the Service Catalog product"
  value       = var.create_service_catalog ? aws_servicecatalog_product.amazon_linux_3[0].arn : null
}

# =============================================================================
# PROVISIONED PRODUCT OUTPUTS
# =============================================================================

output "provisioned_product_id" {
  description = "ID of the provisioned product"
  value       = var.provision_ec2_instance && var.create_service_catalog ? aws_servicecatalog_provisioned_product.ec2_instance[0].id : null
}

output "provisioned_product_arn" {
  description = "ARN of the provisioned product"
  value       = var.provision_ec2_instance && var.create_service_catalog ? aws_servicecatalog_provisioned_product.ec2_instance[0].arn : null
}

output "provisioned_product_outputs" {
  description = "Outputs from the provisioned product"
  value       = var.provision_ec2_instance && var.create_service_catalog ? aws_servicecatalog_provisioned_product.ec2_instance[0].outputs : null
}

# =============================================================================
# IAM ROLE OUTPUTS
# =============================================================================

output "service_catalog_role_name" {
  description = "Name of the Service Catalog IAM role"
  value       = var.create_service_catalog ? aws_iam_role.service_catalog[0].name : null
}

output "service_catalog_role_arn" {
  description = "ARN of the Service Catalog IAM role"
  value       = var.create_service_catalog ? aws_iam_role.service_catalog[0].arn : null
}

# =============================================================================
# EC2 INSTANCE OUTPUTS
# =============================================================================

output "ec2_instance_id" {
  description = "ID of the EC2 instance created via Service Catalog"
  value       = local.ec2_instance_id
}

# =============================================================================
# IAM INSTANCE PROFILE OUTPUTS
# =============================================================================

output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = var.create_iam_instance_profile ? aws_iam_role.ec2[0].arn : null
}

output "ec2_iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = var.create_iam_instance_profile ? aws_iam_role.ec2[0].name : null
}

output "ec2_instance_profile_arn" {
  description = "ARN of the EC2 instance profile"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.ec2[0].arn : null
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.ec2[0].name : null
}

# =============================================================================
# ACCOUNT OUTPUTS
# =============================================================================

output "account_id" {
  description = "Current AWS account ID"
  value       = local.account_id
}

# =============================================================================
# LABELS OUTPUTS
# =============================================================================

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