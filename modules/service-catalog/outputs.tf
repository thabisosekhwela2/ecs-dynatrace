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