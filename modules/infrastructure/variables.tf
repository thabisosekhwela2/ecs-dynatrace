# =============================================================================
# CONTEXT VARIABLES
# =============================================================================

variable "enabled" {
  description = "Whether to create resources"
  type        = bool
  default     = true
}

variable "context" {
  description = "Single object for setting entire context at once"
  type = object({
    enabled             = optional(bool, true)
    namespace           = optional(string, "")
    environment         = optional(string, "")
    stage               = optional(string, "")
    name                = optional(string, "")
    delimiter           = optional(string, "-")
    attributes          = optional(list(string), [])
    tags                = optional(map(string), {})
    additional_tag_map  = optional(map(string), {})
    regex_replace_chars = optional(string, "/[^a-zA-Z0-9-]/")
    label_order         = optional(list(string), [])
    id_length_limit     = optional(number, null)
    label_key_case      = optional(string, "lower")
    label_value_case    = optional(string, "lower")
  })
  default = {}
}

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
  type        = string
  default     = ""
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'"
  type        = string
  default     = ""
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = string
  default     = ""
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
}

# =============================================================================
# SERVICE CATALOG CONFIGURATION VARIABLES
# =============================================================================

variable "create_service_catalog" {
  description = "Whether to create Service Catalog resources"
  type        = bool
  default     = true
}

variable "provision_ec2_instance" {
  description = "Whether to provision an EC2 instance via Service Catalog"
  type        = bool
  default     = false
}

# =============================================================================
# SERVICE CATALOG DETAILS VARIABLES
# =============================================================================

variable "portfolio_description" {
  description = "Description for the Service Catalog portfolio"
  type        = string
  default     = "Portfolio for EC2 instances and related services"
}

variable "provider_name" {
  description = "Provider name for the Service Catalog portfolio"
  type        = string
  default     = "Infrastructure Team"
}

variable "product_owner" {
  description = "Owner of the Service Catalog product"
  type        = string
  default     = "Infrastructure Team"
}

variable "product_description" {
  description = "Description for the Service Catalog product"
  type        = string
  default     = "Amazon Linux 3 EC2 Instance with IAM role support"
}

variable "product_distributor" {
  description = "Distributor of the Service Catalog product"
  type        = string
  default     = "Infrastructure Team"
}

variable "support_description" {
  description = "Support description for the Service Catalog product"
  type        = string
  default     = "Contact the Infrastructure Team for support"
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
  description = "URL of the CloudFormation template for the Service Catalog product"
  type        = string
  default     = "https://s3.amazonaws.com/ec2-service-catalog-templates/templates/ec2-amazon-linux-3.yaml"
}

variable "principal_arn" {
  description = "ARN of the principal to associate with the portfolio"
  type        = string
  default     = ""
}

# =============================================================================
# EC2 INSTANCE VARIABLES
# =============================================================================

variable "instance_type" {
  description = "EC2 instance type to use for the provisioned product"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
  default     = ""
  
  validation {
    condition     = var.vpc_id == "" || can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-' or be empty."
  }
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
  default     = ""
  
  validation {
    condition     = var.subnet_id == "" || can(regex("^subnet-", var.subnet_id))
    error_message = "Subnet ID must start with 'subnet-' or be empty."
  }
}

variable "key_pair_name" {
  description = "Key pair name for SSH access to the EC2 instance"
  type        = string
  default     = ""
}

# =============================================================================
# IAM INSTANCE PROFILE VARIABLES
# =============================================================================

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM instance profile for the EC2 instance"
  type        = bool
  default     = false
}

variable "iam_role_description" {
  description = "Description for the EC2 IAM role"
  type        = string
  default     = "IAM role for EC2 instance created via Service Catalog"
}

variable "use_permissions_boundary" {
  description = "Whether to use a permissions boundary for IAM roles"
  type        = bool
  default     = false
}

variable "ec2_role_additional_policies" {
  description = "Additional IAM policies to attach to the EC2 role"
  type        = list(string)
  default     = []
}

# =============================================================================
# SECURITY GROUP VARIABLES
# =============================================================================

variable "security_group_ingress_rules" {
  description = "Security group ingress rules as JSON string"
  type        = string
  default     = ""
}

variable "security_group_egress_rules" {
  description = "Security group egress rules as JSON string"
  type        = string
  default     = ""
}

# =============================================================================
# PROVISIONING PARAMETERS VARIABLES
# =============================================================================

variable "provisioning_parameters" {
  description = "Dynamic provisioning parameters for the Service Catalog product"
  type = list(object({
    key   = string
    value = string
  }))
  default = [
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
      value = ""
    },
    {
      key   = "SubnetId"
      value = ""
    }
  ]
} 