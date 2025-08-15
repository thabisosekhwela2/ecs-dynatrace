# General variables
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "EC2-Service-Catalog"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Infrastructure Team"
}

# Service Catalog variables
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
  default     = "https://s3.amazonaws.com/your-bucket/templates/ec2-amazon-linux-3.yaml"
}

variable "principal_arn" {
  description = "ARN of the principal to associate with the portfolio"
  type        = string
}

# EC2 Instance variables
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "amazon-linux-3-instance"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If not provided, will use latest Amazon Linux 3"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the instance will be launched. If not provided, will use default VPC"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where the instance can be launched. If not provided, will use default subnets"
  type        = list(string)
  default     = null
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "dynatrace_cidr_blocks" {
  description = "CIDR blocks allowed for Dynatrace ActiveGate communication"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

# Dynatrace variables
variable "dynatrace_environment_url" {
  description = "Dynatrace environment URL (e.g., abc12345.live.dynatrace.com)"
  type        = string
}

variable "dynatrace_token" {
  description = "Dynatrace API token for ActiveGate installation"
  type        = string
  sensitive   = true
}

variable "activegate_version" {
  description = "Dynatrace ActiveGate version to install"
  type        = string
  default     = "latest"
} 