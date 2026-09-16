data "aws_iam_policy_document" "application_data" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.application_data.arn,
      "${aws_s3_bucket.application_data.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "application_data" {
  bucket = aws_s3_bucket.application_data.id
  policy = data.aws_iam_policy_document.application_data.json

  depends_on = [
    aws_s3_bucket_public_access_block.application_data
  ]
}
