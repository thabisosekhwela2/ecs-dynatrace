# Service Catalog Portfolio
resource "aws_servicecatalog_portfolio" "main" {
  name          = var.portfolio_name
  description   = var.portfolio_description
  provider_name = var.provider_name
}

# Service Catalog Product
resource "aws_servicecatalog_product" "amazon_linux_3" {
  name        = var.product_name
  owner       = var.product_owner
  description = var.product_description
  distributor = var.product_distributor
  support_description = var.support_description
  support_email = var.support_email
  support_url = var.support_url
  type        = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    template_url = var.template_url
    name         = "v1.0"
    type         = "CLOUD_FORMATION_TEMPLATE"
    description  = "Amazon Linux 3 EC2 Instance with Dynatrace ActiveGate"
  }

  tags = var.tags
}

# Associate Product with Portfolio
resource "aws_servicecatalog_product_portfolio_association" "main" {
  portfolio_id = aws_servicecatalog_portfolio.main.id
  product_id   = aws_servicecatalog_product.amazon_linux_3.id
}

# IAM Role for Service Catalog
resource "aws_iam_role" "service_catalog" {
  name = "${var.portfolio_name}-service-catalog-role"

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

  tags = var.tags
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