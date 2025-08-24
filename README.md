# EC2 Service Catalog with Service Actions

This project demonstrates a clean approach to deploying EC2 instances via AWS Service Catalog and managing security groups through Service Actions, all orchestrated with Terraform and Terragrunt.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Terraform/Terragrunt                        │
├─────────────────────────────────────────────────────────────────┤
│  Infrastructure Module                                          │
│  ├── Service Catalog Portfolio                                 │
│  ├── Service Catalog Product                                   │
│  ├── Custom SSM Document (Security Group Manager)              │
│  ├── Service Action (Security Group Manager)                   │
│  └── Provisioned Product (EC2 Instance)                        │
├─────────────────────────────────────────────────────────────────┤
│  Service Action Manager Module (AWSCC Provider)                │
│  └── Service Action Association                                │
├─────────────────────────────────────────────────────────────────┤
│  Service Action Trigger Module                                 │
│  └── Service Action Execution                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. **Infrastructure Module** (`modules/infrastructure/`)
- **Service Catalog Portfolio**: Container for organizing products
- **Service Catalog Product**: Defines the EC2 instance template
- **Custom SSM Document**: Automation document for security group management
- **Service Action**: Links the SSM document to the Service Catalog product
- **Provisioned Product**: The actual EC2 instance deployment

### 2. **Service Action Manager Module** (`modules/service-action-manager/`)
- Uses the AWSCC provider to manage service action associations
- Associates service actions with products and provisioning artifacts

### 3. **Service Action Trigger Module** (`modules/service-action-trigger/`)
- Demonstrates how to trigger service actions with custom parameters
- Accepts security group configuration (CIDR blocks, ports, protocols)

## Directory Structure

```
├── modules/
│   ├── infrastructure/              # Service Catalog infrastructure
│   ├── service-action-manager/      # AWSCC service action associations
│   ├── service-action-trigger/      # Service action execution
│   └── labels/                      # Standardized naming and tagging
├── environments/
│   ├── dev/                         # Development environment
│   ├── service-action-association/  # Service action associations
│   └── service-action-demo/         # Service action trigger demo
├── templates/                       # CloudFormation templates
└── README.md                        # This file
```

## Quick Start

### 1. Deploy Service Catalog Infrastructure

```bash
cd environments/dev
terragrunt apply
```

This creates:
- Service Catalog portfolio and product
- Custom SSM document for security group management
- Service action for security group operations
- EC2 instance via Service Catalog

### 2. Associate Service Action (Optional)

```bash
cd environments/service-action-association
terragrunt apply
```

This associates the service action with the product using the AWSCC provider.

### 3. Trigger Service Action (Demo)

```bash
cd environments/service-action-demo
terragrunt apply
```

This demonstrates how to trigger the service action with custom security group parameters.

## Security Group Management

The service action accepts the following parameters:

```hcl
security_group_parameters = {
  security_group_name = "ec2-dev-security-group"
  vpc_id = "vpc-017a01d64a7dce04f"
  description = "Security group for EC2 instance"
  ingress_rules = [
    {
      description = "SSH access"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTP access"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      description = "All outbound traffic"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
```

## Benefits of This Approach

1. **Separation of Concerns**: EC2 deployment and security group management are separate
2. **Reusability**: Service actions can be reused across multiple products
3. **Parameterization**: Full control over security group configuration
4. **Terraform Native**: All managed through Terraform/Terragrunt
5. **AWSCC Integration**: Uses AWS Cloud Control API for service action associations
6. **Clean Architecture**: Removed complex IAM role attachment logic

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform and Terragrunt installed
- S3 backend configured for Terraform state
- CloudFormation template uploaded to S3

## Configuration

### Environment Variables

Set the following environment variables:

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=af-south-1
```

### Backend Configuration

The project uses S3 backend for Terraform state. Configure in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "ec2-service-catalog/terraform.tfstate"
    region = "af-south-1"
  }
}
```

## Troubleshooting

### Common Issues

1. **Service Action Association Fails**: Ensure the AWSCC provider is properly configured
2. **SSM Document Creation Fails**: Check IAM permissions for SSM document creation
3. **Service Action Execution Fails**: Verify the service action parameters are correctly formatted

### Logs and Debugging

- Check CloudWatch logs for SSM automation execution
- Review Service Catalog provisioned product status
- Monitor EC2 instance security group attachments

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 