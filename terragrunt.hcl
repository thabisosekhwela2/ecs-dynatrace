# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"
  config = {
    bucket         = "ec2-service-catalog-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure root level variables that all resources can inherit
inputs = {
  aws_region = "af-south-1"
  
  # General settings
  environment = "dev"
  project_name = "EC2-Service-Catalog"
  owner = "Infrastructure Team"
  
  # Service Catalog settings
  portfolio_name = "EC2-Instance-Portfolio"
  portfolio_description = "Portfolio for EC2 instances with monitoring capabilities"
  provider_name = "Infrastructure Team"
  product_name = "Amazon-Linux-3-EC2-Instance"
  product_owner = "Infrastructure Team"
  product_description = "Amazon Linux 3 EC2 instance with Dynatrace ActiveGate monitoring"
  product_distributor = "Infrastructure Team"
  support_description = "Contact infrastructure team for support"
  support_email = "infrastructure@company.com"
  support_url = "https://company.com/support"
  
  # EC2 Instance settings
  instance_name = "amazon-linux-3-instance"
  instance_type = "t3.medium"
  root_volume_size = 20
  root_volume_type = "gp3"
  
  # Security settings
  ssh_cidr_blocks = ["0.0.0.0/0"]
  dynatrace_cidr_blocks = ["0.0.0.0/0"]
  
  # Dynatrace settings
  activegate_version = "latest"
  
  # Tags
  tags = {
    Environment = "dev"
    Project     = "EC2-Service-Catalog"
    ManagedBy   = "Terragrunt"
    Owner       = "Infrastructure Team"
  }
} 