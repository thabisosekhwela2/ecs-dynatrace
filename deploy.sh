#!/bin/bash

# EC2 Service Catalog Deployment Script
# This script automates the deployment of the EC2 Service Catalog with Dynatrace ActiveGate

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Terragrunt is installed
    if ! command -v terragrunt &> /dev/null; then
        print_error "Terragrunt is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites are met!"
}

# Function to validate environment
validate_environment() {
    local environment=$1
    
    if [[ ! -d "environments/$environment" ]]; then
        print_error "Environment '$environment' does not exist. Available environments:"
        ls -1 environments/
        exit 1
    fi
    
    print_success "Environment '$environment' is valid!"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    local environment=$1
    
    print_status "Deploying infrastructure for environment: $environment"
    
    cd "environments/$environment"
    
    # Initialize Terragrunt
    print_status "Initializing Terragrunt..."
    terragrunt init
    
    # Plan deployment
    print_status "Planning deployment..."
    terragrunt plan
    
    # Ask for confirmation
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled by user."
        exit 0
    fi
    
    # Apply deployment
    print_status "Applying deployment..."
    terragrunt apply -auto-approve
    
    # Get outputs
    print_status "Getting deployment outputs..."
    terragrunt output
    
    cd ../..
    
    print_success "Infrastructure deployment completed!"
}

# Function to destroy infrastructure
destroy_infrastructure() {
    local environment=$1
    
    print_status "Destroying infrastructure for environment: $environment"
    
    cd "environments/$environment"
    
    # Ask for confirmation
    read -p "Are you sure you want to destroy the infrastructure? This action cannot be undone! (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Destruction cancelled by user."
        exit 0
    fi
    
    # Destroy infrastructure
    print_status "Destroying infrastructure..."
    terragrunt destroy -auto-approve
    
    cd ../..
    
    print_success "Infrastructure destruction completed!"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] COMMAND [ENVIRONMENT]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy infrastructure for the specified environment"
    echo "  destroy   Destroy infrastructure for the specified environment"
    echo "  plan      Plan deployment for the specified environment"
    echo "  validate  Validate the configuration"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Environments:"
    echo "  dev           Development environment"
    echo "  prod          Production environment"
    echo ""
    echo "Examples:"
    echo "  $0 deploy dev"
    echo "  $0 destroy prod"
    echo "  $0 plan dev"
}

# Function to plan deployment
plan_deployment() {
    local environment=$1
    
    print_status "Planning deployment for environment: $environment"
    
    cd "environments/$environment"
    
    # Initialize Terragrunt
    terragrunt init
    
    # Plan deployment
    terragrunt plan
    
    cd ../..
}

# Function to validate configuration
validate_configuration() {
    print_status "Validating configuration..."
    
    # Check if required files exist
    local required_files=(
        "main.tf"
        "variables.tf"
        "outputs.tf"
        "terragrunt.hcl"
        "modules/service-catalog/main.tf"
        "modules/ec2-instance/main.tf"
        "modules/ssm-automation/main.tf"
        "templates/ec2-amazon-linux-3.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Check if environment directories exist
    if [[ ! -d "environments/dev" ]] || [[ ! -d "environments/prod" ]]; then
        print_error "Environment directories are missing"
        exit 1
    fi
    
    print_success "Configuration validation passed!"
}

# Main script logic
main() {
    local command=""
    local environment=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            deploy|destroy|plan|validate)
                command=$1
                shift
                ;;
            dev|prod)
                environment=$1
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if command is provided
    if [[ -z "$command" ]]; then
        print_error "No command specified"
        show_usage
        exit 1
    fi
    
    # Handle validate command
    if [[ "$command" == "validate" ]]; then
        check_prerequisites
        validate_configuration
        exit 0
    fi
    
    # Check if environment is provided for other commands
    if [[ -z "$environment" ]]; then
        print_error "No environment specified for command: $command"
        show_usage
        exit 1
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Validate environment
    validate_environment "$environment"
    
    # Execute command
    case $command in
        deploy)
            deploy_infrastructure "$environment"
            ;;
        destroy)
            destroy_infrastructure "$environment"
            ;;
        plan)
            plan_deployment "$environment"
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 