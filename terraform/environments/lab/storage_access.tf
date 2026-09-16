data "aws_iam_policy_document" "application_data_access" {
  statement {
    sid    = "ListApplicationDataBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      module.storage.bucket_arn
    ]
  }

  statement {
    sid    = "ManageApplicationDataObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${module.storage.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "application_data_access" {
  name        = "${var.project_name}-${var.environment}-application-data-access"
  description = "Least-privilege S3 access for application workloads."
  policy      = data.aws_iam_policy_document.application_data_access.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "application_data_access" {
  role       = module.iam.ec2_workload_role_name
  policy_arn = aws_iam_policy.application_data_access.arn
}
