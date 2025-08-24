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

output "service_action_id" {
  description = "ID of the Service Catalog service action"
  value       = var.create_service_catalog ? aws_servicecatalog_service_action.security_group_manager[0].id : null
}

output "service_action_association_id" {
  description = "ID of the Service Catalog service action association"
  value       = var.create_service_catalog ? awscc_servicecatalog_service_action_association.security_group_manager[0].id : null
}

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

output "service_catalog_role_arn" {
  description = "ARN of the Service Catalog IAM role"
  value       = var.create_service_catalog ? aws_iam_role.service_catalog[0].arn : null
}

output "service_catalog_role_name" {
  description = "Name of the Service Catalog IAM role"
  value       = var.create_service_catalog ? aws_iam_role.service_catalog[0].name : null
} 