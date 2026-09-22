# =============================================================================
# Attribute-Based Access Control (ABAC)
# =============================================================================
#
# Demonstrates authorization based on AWS resource tags.
#
# Developers may start/stop EC2 instances only when:
#
#   Environment = lab
#   Project     = sidiqi-aws-enterprise-cloud-lab
#
# This complements the RBAC developer role with resource-level attributes.
# =============================================================================

data "aws_iam_policy_document" "developer_abac" {

  statement {
    sid    = "ManageApprovedLabInstances"
    effect = "Allow"

    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances"
    ]

    resources = ["arn:aws:ec2:*:${var.expected_account_id}:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project_name]
    }
  }
}

resource "aws_iam_policy" "developer_abac" {
  name        = "${var.project_name}-${var.environment}-developer-abac-policy"
  description = "ABAC policy restricting developer operations to approved project and environment resources."
  policy      = data.aws_iam_policy_document.developer_abac.json

  tags = {
    AccessModel   = "ABAC"
    Purpose       = "DeveloperAccess"
    SecurityModel = "ICAM"
  }
}

resource "aws_iam_role_policy_attachment" "developer_abac" {
  role       = aws_iam_role.developer.name
  policy_arn = aws_iam_policy.developer_abac.arn
}
