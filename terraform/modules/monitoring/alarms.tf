resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${local.name_prefix}-asg-high-cpu"
  alarm_description   = "Application Auto Scaling Group average CPU utilization is high."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name          = "${local.name_prefix}-alb-unhealthy-targets"
  alarm_description   = "Application Load Balancer has unhealthy targets."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.load_balancer_dimension
    TargetGroup  = local.target_group_dimension
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${local.name_prefix}-alb-5xx"
  alarm_description   = "Application Load Balancer is returning HTTP 5XX errors."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.load_balancer_dimension
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name          = "${local.name_prefix}-alb-high-latency"
  alarm_description   = "Application Load Balancer target response time is high."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  extended_statistic  = "p95"
  period              = 300
  evaluation_periods  = 2
  threshold           = 2
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.load_balancer_dimension
    TargetGroup  = local.target_group_dimension
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name_prefix}-rds-high-cpu"
  alarm_description   = "RDS CPU utilization is high."
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${local.name_prefix}-rds-low-storage"
  alarm_description   = "RDS free storage has fallen below 5 GiB."
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 5368709120
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${local.name_prefix}-dynamodb-throttles"
  alarm_description   = "DynamoDB requests are being throttled."
  namespace           = "AWS/DynamoDB"
  metric_name         = "ThrottledRequests"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  alarm_actions = [aws_sns_topic.monitoring.arn]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
resource "aws_cloudwatch_metric_alarm" "asg_memory_high" {
  alarm_name          = "${local.name_prefix}-asg-high-memory"
  alarm_description   = "Application Auto Scaling Group memory utilization is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80

  namespace   = "CWAgent"
  metric_name = "mem_used_percent"
  statistic   = "Average"
  period      = 300

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]
}

resource "aws_cloudwatch_metric_alarm" "asg_disk_high" {
  alarm_name          = "${local.name_prefix}-asg-high-disk"
  alarm_description   = "Application Auto Scaling Group disk utilization is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = 80

  namespace   = "CWAgent"
  metric_name = "disk_used_percent"
  statistic   = "Maximum"
  period      = 300

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.monitoring.arn]
  ok_actions    = [aws_sns_topic.monitoring.arn]
}
