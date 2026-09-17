data "aws_iam_policy_document" "terraform_deployment_permissions" {
  statement {
    sid    = "ReadIAMConfiguration"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListPolicyVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageProjectIAMRoles"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]

    resources = [
      "arn:aws:iam::${var.expected_account_id}:role/${var.project_name}-${var.environment}-*",
    ]
  }

  statement {
    sid    = "ManageEBSLifecyclePolicies"
    effect = "Allow"

    actions = [
      "dlm:CreateLifecyclePolicy",
      "dlm:GetLifecyclePolicy",
      "dlm:UpdateLifecyclePolicy",
      "dlm:DeleteLifecyclePolicy",
      "dlm:ListTagsForResource",
      "dlm:TagResource",
      "dlm:UntagResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PassDLMServiceRole"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = [
      "arn:aws:iam::${var.expected_account_id}:role/${var.project_name}-${var.environment}-dlm-*",
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["dlm.amazonaws.com"]
    }
  }

  statement {
    sid    = "ManageRDS"
    effect = "Allow"

    actions = [
      "rds:AddTagsToResource",
      "rds:CreateDBInstance",
      "rds:CreateDBSubnetGroup",
      "rds:DeleteDBInstance",
      "rds:DeleteDBSubnetGroup",
      "rds:DescribeDBInstances",
      "rds:DescribeDBSubnetGroups",
      "rds:DescribeDBEngineVersions",
      "rds:DescribeOrderableDBInstanceOptions",
      "rds:ListTagsForResource",
      "rds:ModifyDBInstance",
      "rds:ModifyDBSubnetGroup",
      "rds:RemoveTagsFromResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageRDSMasterUserSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:ListSecretVersionIds",
      "secretsmanager:ListSecrets",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
    ]

    resources = ["*"]
  }
  statement {
    sid    = "ManageDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DeleteTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:ListTagsOfResource",
      "dynamodb:TagResource",
      "dynamodb:UntagResource",
      "dynamodb:UpdateContinuousBackups",
      "dynamodb:UpdateTable",
    ]

    resources = [
      "arn:aws:dynamodb:*:${var.expected_account_id}:table/${var.project_name}-${var.environment}-*",
    ]
  }

  statement {
    sid    = "ManageProjectIAMPolicies"
    effect = "Allow"

    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:UntagPolicy",
    ]

    resources = [
      "arn:aws:iam::${var.expected_account_id}:policy/${var.project_name}-${var.environment}-*",
    ]
  }
}

resource "aws_iam_policy" "terraform_deployment" {
  name        = "${var.project_name}-${var.environment}-terraform-deployment-policy"
  description = "Least-privilege foundational permissions for Terraform deployment automation."
  policy      = data.aws_iam_policy_document.terraform_deployment_permissions.json

  tags = {
    Purpose = "TerraformDeployment"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_deployment" {
  role       = aws_iam_role.terraform_deployment.name
  policy_arn = aws_iam_policy.terraform_deployment.arn
}

resource "aws_iam_role_policy_attachment" "administrative" {
  role       = aws_iam_role.administrative.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_workload_ssm" {
  role       = aws_iam_role.ec2_workload.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_workload_cloudwatch" {
  role       = aws_iam_role.ec2_workload.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
