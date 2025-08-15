variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance. If not provided, will use latest Amazon Linux 3"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where the instance will be launched. If not provided, will use default VPC"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where the instance can be launched. If not provided, will use default subnets"
  type        = list(string)
  default     = null
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

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp3"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 