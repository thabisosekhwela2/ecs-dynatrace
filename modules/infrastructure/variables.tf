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
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'"
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

variable "delimiter" {
  description = "Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`"
  type        = string
  default     = "-"
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

variable "additional_tag_map" {
  description = "Additional tags for appending to each tag map"
  type        = map(string)
  default     = {}
}

variable "label_order" {
  description = "The naming order of the id output and Name tag"
  type        = list(string)
  default     = []
}

variable "regex_replace_chars" {
  description = "Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed"
  type        = string
  default     = "/[^a-zA-Z0-9-]/"
}

variable "id_length_limit" {
  description = "Limit `id` to this many characters (minimum 6). Set to `0` for unlimited length. Set to `null` for keep the existing setting, which defaults to `0`. Does not affect `id_full`"
  type        = number
  default     = null
}

variable "label_key_case" {
  description = "The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`"
  type        = string
  default     = "lower"
  validation {
    condition     = contains(["lower", "title", "upper"], var.label_key_case)
    error_message = "The label_key_case must be one of: lower, title, upper."
  }
}

variable "label_value_case" {
  description = "The letter case of output label values (i.e. `name`, `namespace`, `environment`, `stage`) to use in `tags`"
  type        = string
  default     = "lower"
  validation {
    condition     = contains(["lower", "title", "upper"], var.label_value_case)
    error_message = "The label_value_case must be one of: lower, title, upper."
  }
}

# =============================================================================
# SERVICE CATALOG VARIABLES
# =============================================================================

variable "create_service_catalog" {
  description = "Whether to create Service Catalog resources"
  type        = bool
  default     = true
}

variable "provision_ec2_instance" {
  description = "Whether to provision an EC2 instance via Service Catalog"
  type        = bool
  default     = true
}

variable "portfolio_description" {
  description = "Description of the Service Catalog portfolio"
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
  description = "Description of the Service Catalog product"
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
  default     = "https://ec2-service-catalog-templates.s3.amazonaws.com/ec2-amazon-linux-3.yaml"
}

variable "principal_arn" {
  description = "ARN of the principal to associate with the Service Catalog portfolio"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type to use for the provisioned product"
  type        = string
  default     = "t3.micro"
}

# =============================================================================
# VPC AND NETWORKING VARIABLES
# =============================================================================

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be deployed"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Key pair name for SSH access to the EC2 instance"
  type        = string
  default     = ""
} 