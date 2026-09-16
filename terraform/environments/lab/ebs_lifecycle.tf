data "aws_iam_policy_document" "dlm_assume_role" {
  statement {
    sid     = "AllowDLMServiceAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["dlm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dlm_lifecycle" {
  name = "${var.project_name}-${var.environment}-dlm-ebs-lifecycle-role"

  description        = "Service role used by Amazon Data Lifecycle Manager for EBS snapshots."
  assume_role_policy = data.aws_iam_policy_document.dlm_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "dlm_lifecycle" {
  statement {
    sid    = "ManageEBSSnapshots"
    effect = "Allow"

    actions = [
      "ec2:CreateSnapshot",
      "ec2:CreateSnapshots",
      "ec2:DeleteSnapshot",
      "ec2:DescribeVolumes",
      "ec2:DescribeSnapshots",
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageSnapshotTags"
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags",
    ]

    resources = ["arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:snapshot/*"]
  }
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "${var.project_name}-${var.environment}-dlm-ebs-lifecycle-policy"
  role   = aws_iam_role.dlm_lifecycle.id
  policy = data.aws_iam_policy_document.dlm_lifecycle.json
}

resource "aws_dlm_lifecycle_policy" "application_ebs" {
  description        = "Daily snapshots for lab application EBS volumes"
  execution_role_arn = aws_iam_role.dlm_lifecycle.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    target_tags = {
      Backup      = "DLM"
      Environment = var.environment
    }

    schedule {
      name = "Daily EBS snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true

      tags_to_add = {
        ManagedBy = "DLM"
        Purpose   = "EBSBackup"
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ebs-snapshot-lifecycle"
    }
  )
}
