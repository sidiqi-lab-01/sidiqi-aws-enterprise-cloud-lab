resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  name        = "AmazonCloudWatch-${local.name_prefix}"
  description = "CloudWatch Agent configuration for application EC2 instances."
  type        = "String"

  value = jsonencode({
    agent = {
      metrics_collection_interval = 60
      run_as_user                 = "root"
    }

    metrics = {
      namespace = "CWAgent"

      append_dimensions = {
        AutoScalingGroupName = "$${aws:AutoScalingGroupName}"
        InstanceId           = "$${aws:InstanceId}"
        InstanceType         = "$${aws:InstanceType}"
      }

      aggregation_dimensions = [
        ["AutoScalingGroupName"],
        ["InstanceId"]
      ]

      metrics_collected = {
        mem = {
          measurement = [
            "mem_used_percent"
          ]
          metrics_collection_interval = 60
        }

        disk = {
          measurement = [
            "used_percent",
            "free"
          ]

          resources = [
            "/"
          ]

          metrics_collection_interval = 60
        }

        swap = {
          measurement = [
            "swap_used_percent"
          ]

          metrics_collection_interval = 60
        }
      }
    }

    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = "/var/log/sidiqi-application-bootstrap.log"
              log_group_name  = aws_cloudwatch_log_group.application.name
              log_stream_name = "{instance_id}/bootstrap"
              timezone        = "UTC"
            },
            {
              file_path       = "/var/log/messages"
              log_group_name  = aws_cloudwatch_log_group.system.name
              log_stream_name = "{instance_id}/messages"
              timezone        = "UTC"
            }
          ]
        }
      }
    }
  })

  tags = {
    Name        = "${local.name_prefix}-cloudwatch-agent-config"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Observability"
  }
}

resource "aws_ssm_association" "cloudwatch_agent_configure" {
  name             = "AmazonCloudWatch-ManageAgent"
  association_name = "${local.name_prefix}-cloudwatch-agent-configure"

  targets {
    key    = "tag:Tier"
    values = ["Application"]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = aws_ssm_parameter.cloudwatch_agent_config.name
    optionalRestart               = "yes"
  }
}
