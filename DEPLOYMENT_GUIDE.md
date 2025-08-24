# Deployment Guide

This guide walks you through deploying the EC2 Service Catalog with Service Actions using Terraform and Terragrunt.

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.0** and **Terragrunt >= 0.45** installed
3. **S3 bucket** for Terraform state storage
4. **CloudFormation template** uploaded to S3

## Step 1: Configure Backend

Update `backend.tf` with your S3 bucket details:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "ec2-service-catalog/terraform.tfstate"
    region = "af-south-1"
    encrypt = true
  }
}
```

## Step 2: Deploy Service Catalog Infrastructure

```bash
cd environments/dev
terragrunt init
terragrunt plan
terragrunt apply
```

This creates:
- Service Catalog portfolio and product
- Custom SSM document for security group management
- Service action for security group operations
- EC2 instance via Service Catalog

## Step 3: Associate Service Action (Optional)

```bash
cd ../service-action-association
terragrunt init
terragrunt apply
```

This associates the service action with the product using the AWSCC provider.

## Step 4: Trigger Service Action (Demo)

```bash
cd ../service-action-demo
terragrunt init
terragrunt apply
```

This demonstrates how to trigger the service action with custom security group parameters.

## Verification

### Check Service Catalog Resources

```bash
# List portfolios
aws servicecatalog list-portfolios

# List products
aws servicecatalog list-products

# List service actions
aws servicecatalog list-service-actions
```

### Check EC2 Instance

```bash
# Get instance details
aws ec2 describe-instances --filters "Name=tag:Name,Values=service-catalog*"

# Check security groups
aws ec2 describe-instances --instance-ids <instance-id> --query 'Reservations[0].Instances[0].SecurityGroups'
```

### Check SSM Document

```bash
# List SSM documents
aws ssm list-documents --filters "Key=Name,Values=*security-group-manager*"
```

## Cleanup

To destroy the infrastructure:

```bash
# Destroy in reverse order
cd environments/service-action-demo
terragrunt destroy

cd ../service-action-association
terragrunt destroy

cd ../dev
terragrunt destroy
```

## Troubleshooting

### Common Issues

1. **Service Action Association Fails**
   - Ensure AWSCC provider is properly configured
   - Check that the service action and product exist

2. **SSM Document Creation Fails**
   - Verify IAM permissions for SSM document creation
   - Check the document content format

3. **Service Action Execution Fails**
   - Verify parameter format (JSON)
   - Check CloudWatch logs for SSM execution

### Useful Commands

```bash
# Check Terragrunt state
terragrunt state list

# Check Terraform outputs
terragrunt output

# Force unlock state (if needed)
terragrunt force-unlock <lock-id>
```

## Next Steps

1. **Customize Security Group Rules**: Modify the security group parameters in the demo environment
2. **Add More Service Actions**: Create additional service actions for other operations
3. **Multi-Environment Deployment**: Create additional environments (staging, production)
4. **Integration**: Integrate with CI/CD pipelines for automated deployments 