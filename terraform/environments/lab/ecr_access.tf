data "aws_iam_policy_document" "ecr_workload_pull" {
  statement {
    sid = "ECRAuthorization"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid = "PullApplicationImages"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = [
      module.ecr.repository_arn
    ]
  }
}

resource "aws_iam_policy" "ecr_workload_pull" {
  name        = "${var.project_name}-${var.environment}-ecr-workload-pull"
  description = "Allows application workloads to pull images from the application ECR repository."
  policy      = data.aws_iam_policy_document.ecr_workload_pull.json

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "ECRWorkloadPull"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_workload_pull" {
  role       = module.iam.ec2_workload_role_name
  policy_arn = aws_iam_policy.ecr_workload_pull.arn
}
