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

variable "tags" {
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`)"
  type        = map(string)
  default     = {}
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