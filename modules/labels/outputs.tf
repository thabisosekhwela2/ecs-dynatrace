output "id" {
  description = "Disambiguated ID"
  value       = module.this.id
}

output "name" {
  description = "Normalized name"
  value       = module.this.name
}

output "namespace" {
  description = "Normalized namespace"
  value       = module.this.namespace
}

output "environment" {
  description = "Normalized environment"
  value       = module.this.environment
}

output "stage" {
  description = "Normalized stage"
  value       = module.this.stage
}

output "tags" {
  description = "Normalized Tag map"
  value       = module.this.tags
}

output "context" {
  description = "Context of this module"
  value       = module.this.context
}

output "label_order" {
  description = "The naming order of the id output and Name tag"
  value       = module.this.label_order
}

output "delimiter" {
  description = "Delimiter between `namespace`, `environment`, `stage`, `name` and `attributes`"
  value       = module.this.delimiter
}

output "attributes" {
  description = "List of attributes"
  value       = module.this.attributes
}

output "enabled" {
  description = "Whether this module is enabled"
  value       = module.this.enabled
} 