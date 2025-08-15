# Service Catalog outputs
output "portfolio_id" {
  description = "ID of the Service Catalog portfolio"
  value       = module.service_catalog.portfolio_id
}

output "portfolio_arn" {
  description = "ARN of the Service Catalog portfolio"
  value       = module.service_catalog.portfolio_arn
}

output "product_id" {
  description = "ID of the Service Catalog product"
  value       = module.service_catalog.product_id
}

output "product_arn" {
  description = "ARN of the Service Catalog product"
  value       = module.service_catalog.product_arn
}

# EC2 Instance outputs
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.instance_public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance.instance_private_ip
}

output "instance_availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = module.ec2_instance.instance_availability_zone
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.ec2_instance.security_group_id
}

# SSM Automation outputs
output "ssm_document_name" {
  description = "Name of the SSM document for Dynatrace ActiveGate installation"
  value       = module.ssm_automation.ssm_document_name
}

output "ssm_document_arn" {
  description = "ARN of the SSM document for Dynatrace ActiveGate installation"
  value       = module.ssm_automation.ssm_document_arn
}

output "maintenance_window_id" {
  description = "ID of the SSM maintenance window"
  value       = module.ssm_automation.maintenance_window_id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for SSM execution logs"
  value       = module.ssm_automation.cloudwatch_log_group_name
}

# Connection information
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = var.key_name != null ? "ssh -i ${var.key_name}.pem ec2-user@${module.ec2_instance.instance_public_ip}" : "SSH key not configured"
}

output "instance_info" {
  description = "Summary of the deployed instance"
  value = {
    instance_id      = module.ec2_instance.instance_id
    instance_name    = var.instance_name
    instance_type    = var.instance_type
    public_ip        = module.ec2_instance.instance_public_ip
    private_ip       = module.ec2_instance.instance_private_ip
    availability_zone = module.ec2_instance.instance_availability_zone
    environment      = var.environment
    region           = "af-south-1"
  }
} 