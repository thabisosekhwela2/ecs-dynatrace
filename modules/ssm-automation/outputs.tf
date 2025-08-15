output "ssm_document_name" {
  description = "Name of the SSM document for Dynatrace ActiveGate installation"
  value       = aws_ssm_document.dynatrace_activegate.name
}

output "ssm_document_arn" {
  description = "ARN of the SSM document for Dynatrace ActiveGate installation"
  value       = aws_ssm_document.dynatrace_activegate.arn
}

# Commented out since we commented out the SSM association resource
# output "ssm_association_id" {
#   description = "ID of the SSM association"
#   value       = aws_ssm_association.dynatrace_activegate.id
# }

output "maintenance_window_id" {
  description = "ID of the SSM maintenance window"
  value       = aws_ssm_maintenance_window.dynatrace.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for SSM execution logs"
  value       = aws_cloudwatch_log_group.ssm_execution.name
}

output "ssm_automation_role_arn" {
  description = "ARN of the IAM role for SSM automation"
  value       = aws_iam_role.ssm_automation.arn
} 