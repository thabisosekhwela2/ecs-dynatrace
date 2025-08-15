# SSM Document for Dynatrace ActiveGate installation
resource "aws_ssm_document" "dynatrace_activegate" {
  name            = "DynatraceActiveGateInstallation"
  document_type   = "Command"
  document_format = "YAML"

  content = templatefile("${path.module}/ssm-document.yaml", {
    dynatraceEnvironmentUrl = var.dynatrace_environment_url
    dynatraceToken          = var.dynatrace_token
    activegateVersion       = var.activegate_version
  })

  tags = var.tags
}

# SSM Association to automatically run the document on the instance
# Commented out since we're using manual trigger approach with null_resource
# resource "aws_ssm_association" "dynatrace_activegate" {
#   name = aws_ssm_document.dynatrace_activegate.name
# 
#   targets {
#     key    = "tag:Name"
#     values = [var.instance_name]
#   }
# 
#   schedule_expression = "rate(30 minutes)"
# 
#   depends_on = [var.instance_id]
# }

# SSM Maintenance Window for Dynatrace installation
resource "aws_ssm_maintenance_window" "dynatrace" {
  name     = "DynatraceActiveGateInstallation"
  schedule = "cron(0 2 ? * SUN *)"  # Every Sunday at 2 AM
  duration = 2
  cutoff   = 1

  tags = var.tags
}

# SSM Maintenance Window Target
resource "aws_ssm_maintenance_window_target" "dynatrace" {
  window_id     = aws_ssm_maintenance_window.dynatrace.id
  name          = "DynatraceTarget"
  description   = "Target for Dynatrace ActiveGate installation"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:Name"
    values = [var.instance_name]
  }
}

# SSM Maintenance Window Task
resource "aws_ssm_maintenance_window_task" "dynatrace" {
  window_id        = aws_ssm_maintenance_window.dynatrace.id
  name             = "DynatraceActiveGateInstallation"
  description      = "Install Dynatrace ActiveGate"
  task_type        = "RUN_COMMAND"
  task_arn         = aws_ssm_document.dynatrace_activegate.arn
  priority         = 1
  max_concurrency  = 1
  max_errors       = 1

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.dynatrace.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "commands"
        values = ["echo 'Dynatrace ActiveGate installation completed'"]
      }
    }
  }
}

# CloudWatch Log Group for SSM execution logs
resource "aws_cloudwatch_log_group" "ssm_execution" {
  name              = "/aws/ssm/execution/${var.instance_name}"
  retention_in_days = 7

  tags = var.tags
}

# IAM Role for SSM Automation
resource "aws_iam_role" "ssm_automation" {
  name = "${var.instance_name}-ssm-automation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for SSM Automation
resource "aws_iam_role_policy" "ssm_automation" {
  name = "${var.instance_name}-ssm-automation-policy"
  role = aws_iam_role.ssm_automation.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
} 