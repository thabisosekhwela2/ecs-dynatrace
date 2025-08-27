# EC2 Service Catalog Infrastructure

This repository contains Terraform and Terragrunt configurations for deploying EC2 instances through AWS Service Catalog with automated security group management.

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Terragrunt    │───▶│  Service Catalog │───▶│   EC2 Instance  │
│   Configuration │    │   (Portfolio)    │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
                       ┌──────────────────┐    ┌─────────────────┐
                       │  CloudFormation  │    │ Security Group  │
                       │    Template      │    │  (Terraform)    │
                       └──────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
.
├── modules/
│   └── infrastructure/          # Main infrastructure module
│       ├── main.tf             # Service Catalog + EC2 + Security Groups
│       ├── variables.tf        # Input variables
│       └── outputs.tf          # Output values
├── environments/
│   └── dev/                    # Development environment
│       └── terragrunt.hcl      # Environment-specific configuration
├── templates/
│   └── ec2-amazon-linux-3.yaml # CloudFormation template
├── terragrunt.hcl              # Root configuration
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0
3. **Terragrunt** >= 0.45
4. **S3 Bucket** for Terraform state (configured in root `terragrunt.hcl`)
5. **DynamoDB Table** for state locking (configured in root `terragrunt.hcl`)

### Deployment

1. **Navigate to environment directory:**
   ```bash
   cd environments/dev
   ```

2. **Initialize Terragrunt:**
   ```bash
   terragrunt init
   ```

3. **Plan the deployment:**
   ```bash
   terragrunt plan
   ```

4. **Apply the configuration:**
   ```bash
   terragrunt apply
   ```

## ⚙️ Configuration

### Environment Variables

The following variables can be customized in `environments/dev/terragrunt.hcl`:

```hcl
inputs = {
  # Service Catalog Configuration
  create_service_catalog = true
  provision_ec2_instance = true
  
  # EC2 Configuration
  instance_type = "t3.micro"
  vpc_id        = "vpc-xxxxxxxxx"
  subnet_id     = "subnet-xxxxxxxxx"
  
  # Security Group Configuration
  security_group_ingress_rules = jsonencode([
    {
      IpProtocol = "tcp"
      FromPort   = 22
      ToPort     = 22
      CidrIp     = "10.0.0.0/8"  # Restrict to VPC CIDR
      Description = "SSH access"
    }
  ])
}
```

### Security Group Rules

Security groups are automatically created and attached to EC2 instances. Configure ingress and egress rules as JSON arrays:

```hcl
security_group_ingress_rules = jsonencode([
  {
    IpProtocol = "tcp"
    FromPort   = 80
    ToPort     = 80
    CidrIp     = "10.0.0.0/8"
    Description = "HTTP access"
  }
])
```

## 🔒 Security Best Practices

### 1. Network Security
- ✅ Use VPC CIDR ranges instead of `0.0.0.0/0`
- ✅ Implement least-privilege security group rules
- ✅ Use private subnets for production workloads

### 2. IAM Security
- ✅ IAM roles with minimal required permissions
- ✅ Support for permissions boundaries
- ✅ Instance profiles for EC2 instances

### 3. State Security
- ✅ S3 backend with encryption
- ✅ DynamoDB state locking
- ✅ No sensitive data in state files

## 🧪 Testing

### Validate Configuration
```bash
terragrunt validate
```

### Plan Changes
```bash
terragrunt plan
```

### Destroy Infrastructure
```bash
terragrunt destroy
```

## 📊 Outputs

After successful deployment, the following outputs are available:

- `ec2_instance_id`: ID of the created EC2 instance
- `portfolio_id`: Service Catalog portfolio ID
- `product_id`: Service Catalog product ID
- `security_group_id`: ID of the created security group

## 🔧 Troubleshooting

### Common Issues

1. **State Lock Issues**
   ```bash
   terragrunt force-unlock <lock-id>
   ```

2. **Provider Version Conflicts**
   ```bash
   terragrunt init -upgrade
   ```

3. **Permission Issues**
   - Ensure AWS credentials have required permissions
   - Check IAM role policies

## 📈 Monitoring

### CloudWatch Metrics
- EC2 instance metrics are automatically available
- Set up CloudWatch alarms for critical metrics

### Service Catalog
- Monitor Service Catalog portfolio usage
- Track provisioned product status

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in this repository
- Contact the Infrastructure Team
- Email: infrastructure@company.com 