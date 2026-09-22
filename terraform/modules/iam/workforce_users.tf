# =============================================================================
# IAM Workforce Simulation
# =============================================================================
# Lab-only workforce identities used to demonstrate:
#
# Identity -> Group -> STS AssumeRole -> RBAC Role -> AWS Resources
#
# Security controls:
# - No console passwords
# - No access keys
# - No direct permissions assigned to individual users
# - Groups may assume only their corresponding RBAC role
# - Target roles retain ICAM permission boundaries
#
# Production workforce access should migrate to IAM Identity Center/federation.
# =============================================================================

locals {
  security_engineering_users = toset([
    "seceng-01",
    "seceng-02",
    "seceng-03",
    "seceng-04",
    "seceng-05"
  ])

  auditor_users = toset([
    "auditor-01",
    "auditor-02",
    "auditor-03",
    "auditor-04",
    "auditor-05"
  ])

  developer_users = toset([
    "developer-01",
    "developer-02",
    "developer-03",
    "developer-04",
    "developer-05",
    "developer-06",
    "developer-07",
    "developer-08",
    "developer-09",
    "developer-10"
  ])

  workforce_users = setunion(
    local.security_engineering_users,
    local.auditor_users,
    local.developer_users
  )
}

# -----------------------------------------------------------------------------
# Workforce IAM users
# -----------------------------------------------------------------------------

resource "aws_iam_user" "workforce" {
  for_each = local.workforce_users

  name = "${var.project_name}-${var.environment}-${each.value}"
  path = "/workforce/"

  force_destroy = false

  tags = {
    IdentityType  = "Workforce"
    AccessModel   = "RBAC"
    SecurityModel = "ICAM"
    Environment   = var.environment
  }
}

# -----------------------------------------------------------------------------
# Workforce groups
# -----------------------------------------------------------------------------

resource "aws_iam_group" "security_engineering" {
  name = "${var.project_name}-${var.environment}-security-engineering"
  path = "/workforce/"
}

resource "aws_iam_group" "auditors" {
  name = "${var.project_name}-${var.environment}-auditors"
  path = "/workforce/"
}

resource "aws_iam_group" "developers" {
  name = "${var.project_name}-${var.environment}-developers"
  path = "/workforce/"
}

# -----------------------------------------------------------------------------
# Group membership
# -----------------------------------------------------------------------------

resource "aws_iam_group_membership" "security_engineering" {
  name = "${var.project_name}-${var.environment}-security-engineering-membership"

  users = [
    for username in local.security_engineering_users :
    aws_iam_user.workforce[username].name
  ]

  group = aws_iam_group.security_engineering.name
}

resource "aws_iam_group_membership" "auditors" {
  name = "${var.project_name}-${var.environment}-auditor-membership"

  users = [
    for username in local.auditor_users :
    aws_iam_user.workforce[username].name
  ]

  group = aws_iam_group.auditors.name
}

resource "aws_iam_group_membership" "developers" {
  name = "${var.project_name}-${var.environment}-developer-membership"

  users = [
    for username in local.developer_users :
    aws_iam_user.workforce[username].name
  ]

  group = aws_iam_group.developers.name
}

# -----------------------------------------------------------------------------
# Security Engineering -> Security Engineer role
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "security_engineering_assume_role" {
  statement {
    sid    = "AssumeSecurityEngineerRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.security_engineer.arn
    ]
  }
}

resource "aws_iam_group_policy" "security_engineering_assume_role" {
  name   = "${var.project_name}-${var.environment}-assume-security-engineer"
  group  = aws_iam_group.security_engineering.name
  policy = data.aws_iam_policy_document.security_engineering_assume_role.json
}

# -----------------------------------------------------------------------------
# Auditors -> Auditor role
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "auditor_assume_role" {
  statement {
    sid    = "AssumeAuditorRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.auditor.arn
    ]
  }
}

resource "aws_iam_group_policy" "auditor_assume_role" {
  name   = "${var.project_name}-${var.environment}-assume-auditor"
  group  = aws_iam_group.auditors.name
  policy = data.aws_iam_policy_document.auditor_assume_role.json
}

# -----------------------------------------------------------------------------
# Developers -> Developer role
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "developer_assume_role" {
  statement {
    sid    = "AssumeDeveloperRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      aws_iam_role.developer.arn
    ]
  }
}

resource "aws_iam_group_policy" "developer_assume_role" {
  name   = "${var.project_name}-${var.environment}-assume-developer"
  group  = aws_iam_group.developers.name
  policy = data.aws_iam_policy_document.developer_assume_role.json
}
