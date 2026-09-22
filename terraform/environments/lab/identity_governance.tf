# =============================================================================
# IAM / ICAM Identity Governance
# =============================================================================

resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "${var.project_name}-${var.environment}-account-access-analyzer"
  type          = "ACCOUNT"

  tags = {
    Name          = "${var.project_name}-${var.environment}-access-analyzer"
    Purpose       = "ExternalAccessAnalysis"
    SecurityModel = "ICAM"
  }
}
