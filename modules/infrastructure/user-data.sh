#!/bin/bash

# Update system
yum update -y

# Install SSM Agent (should already be installed on Amazon Linux 3)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install additional packages
yum install -y \
    jq \
    wget \
    curl \
    unzip \
    git

# Create log directory for Dynatrace
mkdir -p /var/log/dynatrace
chmod 755 /var/log/dynatrace

# Set instance metadata
echo "Instance Name: ${instance_name}" > /etc/instance-info
echo "Environment: ${environment}" >> /etc/instance-info
echo "Deployment Date: $(date)" >> /etc/instance-info

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${instance_name}/system",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dynatrace/*.log",
            "log_group_name": "/aws/ec2/${instance_name}/dynatrace",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Create a marker file to indicate the instance is ready for SSM automation
echo "EC2 instance initialization completed at $(date)" > /var/log/ec2-init-complete.log 