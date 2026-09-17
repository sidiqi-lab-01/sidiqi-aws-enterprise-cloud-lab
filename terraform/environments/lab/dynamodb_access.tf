data "aws_iam_policy_document" "dynamodb_workload_access" {
  statement {
    sid    = "ApplicationStateReadWrite"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:DescribeTable",
    ]

    resources = [
      module.database.dynamodb_table_arn,
    ]
  }
}

resource "aws_iam_policy" "dynamodb_workload_access" {
  name        = "${var.project_name}-${var.environment}-dynamodb-workload-access"
  description = "Least-privilege access to the application-state DynamoDB table."
  policy      = data.aws_iam_policy_document.dynamodb_workload_access.json

  tags = {
    Environment = var.environment
    Purpose     = "DynamoDBWorkloadAccess"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "dynamodb_workload_access" {
  role       = module.iam.ec2_workload_role_name
  policy_arn = aws_iam_policy.dynamodb_workload_access.arn
}
