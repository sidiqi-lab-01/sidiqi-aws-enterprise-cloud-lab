resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = "# AWS Enterprise Cloud Lab — Operations Dashboard\nCentralized infrastructure, application, database, and security observability."
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 8
        height = 6

        properties = {
          title  = "Application EC2 CPU"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 8
        y      = 2
        width  = 8
        height = 6

        properties = {
          title  = "ALB Requests"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              local.load_balancer_dimension
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 16
        y      = 2
        width  = 8
        height = 6

        properties = {
          title  = "ALB Target Response Time"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "p95"

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              local.load_balancer_dimension,
              "TargetGroup",
              local.target_group_dimension
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "ALB HTTP Errors"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              local.load_balancer_dimension
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              ".",
              local.load_balancer_dimension
            ],
            [
              ".",
              "HTTPCode_Target_4XX_Count",
              ".",
              local.load_balancer_dimension
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 8
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "ALB Target Health"
          region = var.aws_region
          view   = "timeSeries"
          period = 60
          stat   = "Average"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HealthyHostCount",
              "LoadBalancer",
              local.load_balancer_dimension,
              "TargetGroup",
              local.target_group_dimension
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              local.load_balancer_dimension,
              ".",
              local.target_group_dimension
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 16
        y      = 8
        width  = 8
        height = 6

        properties = {
          title  = "RDS CPU"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              var.db_instance_id
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "RDS Connections"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              var.db_instance_id
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 8
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "RDS Free Storage"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              var.db_instance_id
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 16
        y      = 14
        width  = 8
        height = 6

        properties = {
          title  = "DynamoDB Throttling"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"

          metrics = [
            [
              "AWS/DynamoDB",
              "ThrottledRequests",
              "TableName",
              var.dynamodb_table_name
            ]
          ]
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 20
        width  = 12
        height = 6

        properties = {
          title  = "Application Host Memory"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "CWAgent",
              "mem_used_percent",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 20
        width  = 12
        height = 6

        properties = {
          title  = "Application Host Disk Usage"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Maximum"

          metrics = [
            [
              "CWAgent",
              "disk_used_percent",
              "AutoScalingGroupName",
              var.autoscaling_group_name
            ]
          ]

          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 26
        width  = 12
        height = 6

        properties = {
          title  = "Application Logs"
          region = var.aws_region

          query = "SOURCE '${aws_cloudwatch_log_group.application.name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
        }
      },

      {
        type   = "log"
        x      = 12
        y      = 26
        width  = 12
        height = 6

        properties = {
          title  = "System Logs"
          region = var.aws_region

          query = "SOURCE '${aws_cloudwatch_log_group.system.name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
        }
      },

      {
        type   = "log"
        x      = 0
        y      = 32
        width  = 24
        height = 6

        properties = {
          title  = "VPC Flow Logs"
          region = var.aws_region

          query = "SOURCE '${var.vpc_flow_log_group_name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
        }
      }
    ]
  })
}
