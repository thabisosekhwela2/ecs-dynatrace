# EC2 Service Catalog with Dynatrace ActiveGate Automation

This project provides a complete Terraform/Terragrunt solution for deploying Amazon Linux 3 EC2 instances through AWS Service Catalog and automating the installation of Dynatrace ActiveGate via SSM.

## Architecture Overview

The solution consists of three main components:

1. **Service Catalog Portfolio & Product**: Manages the deployment of EC2 instances through a standardized catalog
2. **EC2 Instance Module**: Deploys Amazon Linux 3 instances with proper IAM roles and security groups
3. **SSM Automation Module**: Automates the installation and configuration of Dynatrace ActiveGate

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Service Catalog                          │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   Portfolio     │    │    Product      │                    │
│  │                 │    │                 │                    │
│  │ - EC2 Instances │◄──►│ - Amazon Linux 3│                    │
│  │ - Monitoring    │    │ - Dynatrace     │                    │
│  └─────────────────┘    └─────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CloudFormation Template                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ - EC2 Instance (Amazon Linux 3)                            │ │
│  │ - Security Groups (SSH, Dynatrace ports)                   │ │
│  │ - IAM Roles (SSM, CloudWatch)                              │ │
│  │ - User Data (System initialization)                         │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SSM Automation                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │ SSM Document    │    │ SSM Association │    │ Maintenance  │ │
│  │                 │    │                 │    │ Window       │ │
│  │ - Dynatrace     │◄──►│ - Auto-execution│◄──►│ - Scheduled  │ │
│  │   Installation  │    │ - Target tags   │    │   updates    │ │
│  └─────────────────┘    └─────────────────┘    └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Amazon Linux 3 EC2 Instance                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │ System Init     │    │ SSM Agent       │    │ Dynatrace    │ │
│  │                 │    │                 │    │ ActiveGate   │ │
│  │ - Updates       │    │ - Managed       │    │ - Monitoring │ │
│  │ - Packages      │    │ - Automation    │    │ - Gateway    │ │
│  └─────────────────┘    └─────────────────┘    └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

### AWS Requirements
- AWS CLI configured with appropriate permissions
- S3 bucket for Terraform state storage
- DynamoDB table for state locking
- IAM permissions for Service Catalog, EC2, SSM, and CloudWatch

### Dynatrace Requirements
- Dynatrace environment URL
- Dynatrace API token with ActiveGate installation permissions

### Local Requirements
- Terraform >= 1.0
- Terragrunt >= 0.45
- AWS CLI

## Project Structure

```
EC2-Service-Catalog/
├── modules/
│   ├── service-catalog/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2-instance/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user-data.sh
│   └── ssm-automation/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── ssm-document.yaml
├── templates/
│   └── ec2-amazon-linux-3.yaml
├── environments/
│   ├── dev/
│   │   └── terragrunt.hcl
│   └── prod/
│       └── terragrunt.hcl
├── main.tf
├── variables.tf
├── outputs.tf
├── terragrunt.hcl
└── README.md
```

## Configuration

### 1. Update Root Configuration

Edit `terragrunt.hcl` to configure your S3 backend:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "your-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 2. Environment-Specific Configuration

Update the environment-specific configurations in `environments/dev/terragrunt.hcl` and `environments/prod/terragrunt.hcl`:

```hcl
inputs = {
  # Dynatrace settings
  dynatrace_environment_url = "your-environment.live.dynatrace.com"
  dynatrace_token = "your-dynatrace-token"
  
  # Principal ARN for Service Catalog access
  principal_arn = "arn:aws:iam::YOUR-ACCOUNT:user/YOUR-USERNAME"
}
```

### 3. CloudFormation Template URL

Update the `template_url` in your environment configuration to point to your CloudFormation template:

```hcl
template_url = "https://s3.amazonaws.com/your-bucket/templates/ec2-amazon-linux-3.yaml"
```

## Deployment

### 1. Initialize Terragrunt

```bash
# Navigate to the environment directory
cd environments/dev

# Initialize Terragrunt
terragrunt init
```

### 2. Plan the Deployment

```bash
# Review the deployment plan
terragrunt plan
```

### 3. Deploy the Infrastructure

```bash
# Deploy the infrastructure
terragrunt apply
```

### 4. Verify Deployment

After deployment, verify the following:

1. **Service Catalog**: Check that the portfolio and product are created
2. **EC2 Instance**: Verify the instance is running and accessible
3. **SSM Automation**: Check that the SSM document and association are created
4. **Dynatrace ActiveGate**: Verify installation through SSM execution logs

## Usage

### Deploying EC2 Instances via Service Catalog

1. Navigate to AWS Service Catalog console
2. Select your portfolio
3. Choose the Amazon Linux 3 EC2 Instance product
4. Fill in the required parameters
5. Deploy the instance

### Monitoring Dynatrace ActiveGate Installation

1. Check SSM execution logs in CloudWatch
2. Monitor the installation progress in `/var/log/dynatrace/installation.log`
3. Verify ActiveGate service status: `systemctl status dynatracegateway`

### Accessing the Instance

```bash
# SSH access (if key pair is configured)
ssh -i your-key.pem ec2-user@<instance-public-ip>

# Check Dynatrace ActiveGate status
sudo systemctl status dynatracegateway

# View installation logs
sudo tail -f /var/log/dynatrace/installation.log
```

## Security Considerations

### Network Security
- SSH access is restricted to specified CIDR blocks
- Dynatrace ports (9999, 443) are open for monitoring
- All outbound traffic is allowed

### IAM Security
- EC2 instances use least-privilege IAM roles
- SSM automation uses dedicated IAM roles
- Service Catalog has appropriate permissions

### Data Security
- Root volumes are encrypted
- API tokens are marked as sensitive
- State files are encrypted in S3

## Monitoring and Logging

### CloudWatch Integration
- System logs are sent to CloudWatch
- Dynatrace installation logs are captured
- SSM execution logs are stored

### Dynatrace Monitoring
- ActiveGate provides monitoring capabilities
- Application performance monitoring
- Infrastructure monitoring

## Troubleshooting

### Common Issues

1. **SSM Agent Not Running**
   ```bash
   sudo systemctl status amazon-ssm-agent
   sudo systemctl start amazon-ssm-agent
   ```

2. **Dynatrace Installation Fails**
   - Check API token permissions
   - Verify environment URL
   - Review installation logs

3. **Service Catalog Access Denied**
   - Verify principal ARN
   - Check IAM permissions
   - Ensure portfolio association

### Log Locations

- SSM execution logs: CloudWatch `/aws/ssm/execution/<instance-name>`
- Dynatrace installation: `/var/log/dynatrace/installation.log`
- System logs: `/var/log/messages`

## Cost Optimization

### Instance Sizing
- Use appropriate instance types for your workload
- Consider using Spot instances for non-critical workloads
- Monitor and adjust based on usage patterns

### Storage Optimization
- Use GP3 volumes for better performance/cost ratio
- Implement lifecycle policies for logs
- Consider EBS optimization for high I/O workloads

## Maintenance

### Updates
- Dynatrace ActiveGate updates are automated via SSM
- System updates are applied during instance initialization
- Security patches are applied automatically

### Backup
- Consider implementing automated backups for critical data
- Use AWS Backup for comprehensive backup strategies
- Implement disaster recovery procedures

## Support

For issues and questions:
- Check the troubleshooting section
- Review CloudWatch logs
- Contact the infrastructure team

## License

This project is licensed under the MIT License - see the LICENSE file for details. 