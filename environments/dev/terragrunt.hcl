include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/infrastructure"
}

inputs = {
  context = {
    namespace = "ec2"
    environment = "dev"
    stage       = "dev"
    name        = "service-catalog"
    tags = {
      Project     = "EC2-Service-Catalog"
      Owner       = "Infrastructure Team"
      ManagedBy   = "Terragrunt"
      CostCenter  = "Development"
    }
  }

  # Service Catalog Configuration
  create_service_catalog = true
  provision_ec2_instance = true

  # Service Catalog Details
  portfolio_description = "Portfolio for EC2 instances and related services"
  provider_name         = "Infrastructure Team"
  product_owner         = "Infrastructure Team"
  product_description   = "Amazon Linux 3 EC2 Instance with IAM role support"
  product_distributor   = "Infrastructure Team"
  support_description   = "Contact the Infrastructure Team for support"
  support_email         = "infrastructure@company.com"
  support_url           = "https://company.com/support"
  template_url          = "https://s3.amazonaws.com/ec2-service-catalog-templates/templates/ec2-amazon-linux-3.yaml"
  principal_arn         = "arn:aws:iam::581867121447:user/local-user"

  # EC2 Instance Configuration
  instance_type = "t3.micro"

  # VPC Configuration
  vpc_id = "vpc-00fd49b0c733c91a1"
  subnet_id = "subnet-05daad2cbf66df58f"  # Public subnet in af-south-1c
  key_pair_name = ""  # No key pair for now

  # IAM Instance Profile Configuration
  create_iam_instance_profile = true
  iam_role_description = "IAM role for EC2 instance with SSM access"
  use_permissions_boundary = false
  ec2_role_additional_policies = [
    # Add additional policies here if needed
    # "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  # Security Group Configuration (passed to Service Action)
  security_group_ingress_rules = jsonencode([
    {
      IpProtocol = "tcp"
      FromPort   = 22
      ToPort     = 22
      CidrIp     = "0.0.0.0/0"
      Description = "SSH access"
    },
    {
      IpProtocol = "tcp"
      FromPort   = 80
      ToPort     = 80
      CidrIp     = "0.0.0.0/0"
      Description = "HTTP access"
    },
    {
      IpProtocol = "tcp"
      FromPort   = 443
      ToPort     = 443
      CidrIp     = "0.0.0.0/0"
      Description = "HTTPS access"
    },
    {
      IpProtocol = "tcp"
      FromPort   = 9999
      ToPort     = 9999
      CidrIp     = "0.0.0.0/0"
      Description = "Dynatrace ActiveGate port"
    }
  ])

  security_group_egress_rules = jsonencode([
    {
      IpProtocol = "-1"
      CidrIp     = "0.0.0.0/0"
      Description = "All outbound traffic"
    }
  ])

  # Dynamic Provisioning Parameters
  provisioning_parameters = [
    {
      key   = "InstanceType"
      value = "t3.micro"
    },
    {
      key   = "Environment"
      value = "dev"
    },
    {
      key   = "KeyPairName"
      value = ""
    },
    {
      key   = "VpcId"
      value = "vpc-00fd49b0c733c91a1"
    },
    {
      key   = "SubnetId"
      value = "subnet-05daad2cbf66df58f"
    }
  ]
} 