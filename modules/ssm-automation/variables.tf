variable "instance_name" {
  description = "Name of the EC2 instance where Dynatrace ActiveGate will be installed"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance"
  type        = string
}

variable "dynatrace_environment_url" {
  description = "Dynatrace environment URL (e.g., abc12345.live.dynatrace.com)"
  type        = string
}

variable "dynatrace_token" {
  description = "Dynatrace API token for ActiveGate installation"
  type        = string
  sensitive   = true
}

variable "activegate_version" {
  description = "Dynatrace ActiveGate version to install"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 