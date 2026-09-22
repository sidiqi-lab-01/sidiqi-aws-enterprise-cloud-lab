# =============================================================================
# ICAM RBAC Authorization Policies
# =============================================================================


# -----------------------------------------------------------------------------
# Security Engineer
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "security_engineer" {

  statement {
    sid    = "InvestigateIAM"
    effect = "Allow"

    actions = [
      "iam:Get*",
      "iam:List*",
      "access-analyzer:Get*",
      "access-analyzer:List*",
      "cloudtrail:Get*",
      "cloudtrail:Describe*",
      "cloudtrail:LookupEvents",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "security_engineer" {
  name        = "${var.project_name}-${var.environment}-security-engineer-policy"
  description = "Security investigation permissions for the ICAM security engineer role."
  policy      = data.aws_iam_policy_document.security_engineer.json

  tags = {
    AccessModel = "RBAC"
    Purpose     = "SecurityEngineering"
  }
}

resource "aws_iam_role_policy_attachment" "security_engineer" {
  role       = aws_iam_role.security_engineer.name
  policy_arn = aws_iam_policy.security_engineer.arn
}


# -----------------------------------------------------------------------------
# Auditor
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "auditor" {
  role       = aws_iam_role.auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}


# -----------------------------------------------------------------------------
# Developer
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "developer" {

  statement {
    sid    = "ReadApplicationInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadLabData"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer" {
  name        = "${var.project_name}-${var.environment}-developer-policy"
  description = "Least-privilege application infrastructure permissions for developers."
  policy      = data.aws_iam_policy_document.developer.json

  tags = {
    AccessModel = "RBAC"
    Purpose     = "DeveloperAccess"
  }
}

resource "aws_iam_role_policy_attachment" "developer" {
  role       = aws_iam_role.developer.name
  policy_arn = aws_iam_policy.developer.arn
}
