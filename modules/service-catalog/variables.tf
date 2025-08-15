variable "portfolio_name" {
  description = "Name of the Service Catalog portfolio"
  type        = string
  default     = "EC2-Instance-Portfolio"
}

variable "portfolio_description" {
  description = "Description of the Service Catalog portfolio"
  type        = string
  default     = "Portfolio for EC2 instances with monitoring capabilities"
}

variable "provider_name" {
  description = "Provider name for the Service Catalog portfolio"
  type        = string
  default     = "Infrastructure Team"
}

variable "product_name" {
  description = "Name of the Service Catalog product"
  type        = string
  default     = "Amazon-Linux-3-EC2-Instance"
}

variable "product_owner" {
  description = "Owner of the Service Catalog product"
  type        = string
  default     = "Infrastructure Team"
}

variable "product_description" {
  description = "Description of the Service Catalog product"
  type        = string
  default     = "Amazon Linux 3 EC2 instance with Dynatrace ActiveGate monitoring"
}

variable "product_distributor" {
  description = "Distributor of the Service Catalog product"
  type        = string
  default     = "Infrastructure Team"
}

variable "support_description" {
  description = "Support description for the Service Catalog product"
  type        = string
  default     = "Contact infrastructure team for support"
}

variable "support_email" {
  description = "Support email for the Service Catalog product"
  type        = string
  default     = "infrastructure@company.com"
}

variable "support_url" {
  description = "Support URL for the Service Catalog product"
  type        = string
  default     = "https://company.com/support"
}

variable "template_url" {
  description = "URL to the CloudFormation template"
  type        = string
}

variable "principal_arn" {
  description = "ARN of the principal to associate with the portfolio"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 