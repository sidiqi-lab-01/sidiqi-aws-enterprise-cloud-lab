resource "aws_cloudwatch_log_group" "sms" {
  name = "/${var.project_name}/${var.environment}/sms"

  tags = {
    Name        = "${local.name_prefix}-sms-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "SMSObservability"
  }
}

data "aws_iam_policy_document" "sms_cloudwatch_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sms-voice.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sms_cloudwatch" {
  name        = "${var.project_name}-sms-cloudwatch-role"
  description = "Allows AWS End User Messaging SMS to publish SMS delivery events to CloudWatch Logs"

  assume_role_policy = data.aws_iam_policy_document.sms_cloudwatch_assume_role.json

  tags = {
    Name        = "${local.name_prefix}-sms-cloudwatch-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "SMSObservability"
  }
}

data "aws_iam_policy_document" "sms_cloudwatch_logs" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.sms.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "sms_cloudwatch_logs" {
  name   = "SMSCloudWatchLogsPolicy"
  role   = aws_iam_role.sms_cloudwatch.id
  policy = data.aws_iam_policy_document.sms_cloudwatch_logs.json
}

resource "aws_pinpointsmsvoicev2_configuration_set" "monitoring" {
  name = "${var.project_name}-sms"
}

resource "aws_pinpointsmsvoicev2_event_destination" "sms_cloudwatch" {
  configuration_set_name = aws_pinpointsmsvoicev2_configuration_set.monitoring.name
  event_destination_name = "sms-cloudwatch-logs"
  enabled                = true
  matching_event_types   = ["TEXT_ALL"]

  cloudwatch_logs_destination {
    iam_role_arn = aws_iam_role.sms_cloudwatch.arn
    log_group_arn = trimsuffix(
      aws_cloudwatch_log_group.sms.arn,
      ":*"
    )
  }
}
