# =============================================================================
# Enterprise IAM / ICAM
# =============================================================================
#
# Human access is provided through assumable IAM roles rather than long-lived
# IAM user credentials.
#
# RBAC roles:
#   - Security Engineer
#   - Auditor
#   - Developer
#
# These roles are protected by a permissions boundary that defines the maximum
# permissions available to identities created for the ICAM lab.
# =============================================================================


# -----------------------------------------------------------------------------
# Common human identity trust policy
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "human_identity_trust" {
  statement {
    sid     = "AllowTrustedIdentityAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_role_arn]
    }
  }
}


# -----------------------------------------------------------------------------
# ICAM Permission Boundary
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "icam_permission_boundary" {

  statement {
    sid    = "AllowApprovedAWSActions"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "logs:Get*",
      "logs:Describe*",
      "logs:FilterLogEvents",
      "s3:Get*",
      "s3:List*",
      "dynamodb:Describe*",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "ecr:Describe*",
      "ecr:Get*",
      "ecr:List*",
      "iam:Get*",
      "iam:List*",
      "access-analyzer:Get*",
      "access-analyzer:List*",
      "cloudtrail:Get*",
      "cloudtrail:Describe*",
      "cloudtrail:LookupEvents",
      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "icam_permission_boundary" {
  name        = "${var.project_name}-${var.environment}-icam-permission-boundary"
  description = "Maximum permissions boundary for IAM and ICAM workforce roles."
  policy      = data.aws_iam_policy_document.icam_permission_boundary.json

  tags = {
    Purpose       = "PermissionBoundary"
    SecurityModel = "ICAM"
  }
}


# -----------------------------------------------------------------------------
# Security Engineer RBAC Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "security_engineer" {
  name        = "${var.project_name}-${var.environment}-security-engineer-role"
  description = "RBAC role for security engineering and identity investigation."

  assume_role_policy   = data.aws_iam_policy_document.human_identity_trust.json
  permissions_boundary = aws_iam_policy.icam_permission_boundary.arn
  max_session_duration = 3600

  tags = {
    Purpose       = "SecurityEngineering"
    AccessModel   = "RBAC"
    SecurityModel = "ICAM"
    Environment   = var.environment
  }
}


# -----------------------------------------------------------------------------
# Auditor RBAC Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "auditor" {
  name        = "${var.project_name}-${var.environment}-auditor-role"
  description = "Read-only RBAC role for security and compliance auditing."

  assume_role_policy   = data.aws_iam_policy_document.human_identity_trust.json
  permissions_boundary = aws_iam_policy.icam_permission_boundary.arn
  max_session_duration = 3600

  tags = {
    Purpose       = "SecurityAudit"
    AccessModel   = "RBAC"
    SecurityModel = "ICAM"
    Environment   = var.environment
  }
}


# -----------------------------------------------------------------------------
# Developer RBAC Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "developer" {
  name        = "${var.project_name}-${var.environment}-developer-role"
  description = "RBAC role for application developers operating lab resources."

  assume_role_policy   = data.aws_iam_policy_document.human_identity_trust.json
  permissions_boundary = aws_iam_policy.icam_permission_boundary.arn
  max_session_duration = 3600

  tags = {
    Purpose       = "DeveloperAccess"
    AccessModel   = "RBAC"
    SecurityModel = "ICAM"
    Environment   = var.environment
  }
}
