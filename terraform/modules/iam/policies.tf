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
