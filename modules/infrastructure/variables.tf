# Basic naming variables (passed from labels module)
variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation"
  type        = string
  default     = "ec2"
}

variable "environment" {
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'UAT'"
  type        = string
  default     = "dev"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  type        = string
  default     = "dev"
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = string
  default     = "service-catalog"
}

variable "attributes" {
  description = "Additional attributes (e.g. `1`)"
  type        = list(string)
  default     = []
}

variable "context" {
  description = "Default context to use for passing state between label invocations"
  type = object({
    namespace           = optional(string)
    environment         = optional(string)
    stage               = optional(string)
    name                = optional(string)
    enabled             = optional(bool)
    delimiter           = optional(string)
    attributes          = optional(list(string))
    tags                = optional(map(string))
    additional_tag_map  = optional(map(string))
    regex_replace_chars = optional(string)
    label_order         = optional(list(string))
    id_length_limit     = optional(number)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Service Catalog variables
variable "portfolio_description" {
  description = "Description of the Service Catalog portfolio"
  type        = string
  default     = "Portfolio for Amazon Linux 3 EC2 instances with Dynatrace ActiveGate"
}

variable "provider_name" {
  description = "Name of the Service Catalog provider"
  type        = string
  default     = "AWS"
}

variable "product_owner" {
  description = "Owner of the Service Catalog product"
  type        = string
  default     = "DevOps Team"
}

variable "product_description" {
  description = "Description of the Service Catalog product"
  type        = string
  default     = "Amazon Linux 3 EC2 instance with Dynatrace ActiveGate pre-installed"
}

variable "product_distributor" {
  description = "Distributor of the Service Catalog product"
  type        = string
  default     = "AWS"
}

variable "support_description" {
  description = "Support description for the Service Catalog product"
  type        = string
  default     = "Contact DevOps team for support"
}

variable "support_email" {
  description = "Support email for the Service Catalog product"
  type        = string
  default     = "devops@company.com"
}

variable "support_url" {
  description = "Support URL for the Service Catalog product"
  type        = string
  default     = "https://company.com/support"
}

variable "template_url" {
  description = "URL of the CloudFormation template for the Service Catalog product"
  type        = string
}

variable "principal_arn" {
  description = "ARN of the principal to associate with the Service Catalog portfolio"
  type        = string
}

# Service Catalog Provisioning variables
variable "provision_ec2_instance" {
  description = "Whether to provision an EC2 instance via Service Catalog"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type for Service Catalog provisioning"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair for Service Catalog provisioning"
  type        = string
  default     = null
}

# EC2 Instance Management variables
variable "ec2_instance_id" {
  description = "ID of the EC2 instance created via Service Catalog. Leave empty to auto-discover by name tag."
  type        = string
  default     = null
}

variable "ec2_instance_name_tag" {
  description = "Name tag to search for the EC2 instance created via Service Catalog"
  type        = string
  default     = null
}

variable "attach_security_group" {
  description = "Whether to attach a security group to the EC2 instance"
  type        = bool
  default     = true
}

variable "attach_iam_role" {
  description = "Whether to attach an IAM role to the EC2 instance"
  type        = bool
  default     = true
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "dynatrace_cidr_blocks" {
  description = "CIDR blocks allowed for Dynatrace ActiveGate communication"
  type        = list(string)
  default     = ["0.0.0.0/0"]
} 