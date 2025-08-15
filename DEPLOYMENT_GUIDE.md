# Quick Deployment Guide

## Prerequisites

1. **Valid AWS Credentials**: Make sure your AWS credentials are valid and have the necessary permissions
2. **S3 Bucket**: Create an S3 bucket for Terraform state storage
3. **DynamoDB Table**: Create a DynamoDB table for state locking
4. **Dynatrace Credentials**: Get your Dynatrace environment URL and API token

## Configuration Steps

### 1. Update AWS Credentials
```bash
aws configure
```

### 2. Create S3 Bucket and DynamoDB Table
```bash
# Create S3 bucket (replace with your bucket name)
aws s3 mb s3://ec2-service-catalog-terraform-state --region af-south-1

# Create DynamoDB table
aws dynamodb create-table \
    --table-name terraform-locks \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region af-south-1
```

### 3. Update Configuration Files

#### Update `terragrunt.hcl`:
- Replace `ec2-service-catalog-terraform-state` with your actual S3 bucket name

#### Update `environments/dev/terragrunt.hcl`:
- Replace `123456789012` with your actual AWS account ID
- Replace `your-username` with your actual IAM username
- Replace `your-dev-environment.live.dynatrace.com` with your actual Dynatrace environment URL
- Replace `your-dev-dynatrace-token` with your actual Dynatrace API token
- Update the `template_url` to point to your actual S3 bucket where the CloudFormation template is stored

### 4. Upload CloudFormation Template
```bash
# Create S3 bucket for templates
aws s3 mb s3://ec2-service-catalog-templates --region af-south-1

# Upload the CloudFormation template
aws s3 cp templates/ec2-amazon-linux-3.yaml s3://ec2-service-catalog-templates/templates/
```

## Deployment

### Option 1: Using the deployment script
```bash
# Validate configuration
./deploy.sh validate

# Deploy to dev environment
./deploy.sh deploy dev
```

### Option 2: Using Terragrunt directly
```bash
# Navigate to environment directory
cd environments/dev

# Initialize
terragrunt init

# Plan
terragrunt plan

# Apply
terragrunt apply
```

## Verification

After deployment, verify:
1. Service Catalog portfolio and product are created
2. EC2 instance is running
3. SSM automation is configured
4. Dynatrace ActiveGate installation is triggered

## Troubleshooting

- Check AWS credentials: `aws sts get-caller-identity`
- Check S3 bucket access: `aws s3 ls s3://your-bucket-name`
- Check CloudWatch logs for SSM execution
- Check Dynatrace installation logs on the EC2 instance 