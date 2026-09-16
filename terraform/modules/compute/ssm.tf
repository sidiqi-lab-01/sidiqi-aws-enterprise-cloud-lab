resource "aws_ssm_association" "inventory" {
  name = "AWS-GatherSoftwareInventory"

  targets {
    key    = "tag:Tier"
    values = ["Application"]
  }

  schedule_expression = "rate(1 day)"

  parameters = {
    applications                = "Enabled"
    awsComponents               = "Enabled"
    networkConfig               = "Enabled"
    instanceDetailedInformation = "Enabled"
    services                    = "Enabled"
    windowsRoles                = "Disabled"
    windowsUpdates              = "Disabled"
  }

  association_name = "${var.project_name}-${var.environment}-software-inventory"

  apply_only_at_cron_interval = false
}

data "aws_ssm_patch_baseline" "amazon_linux_2023" {
  owner            = "AWS"
  name_prefix      = "AWS-AmazonLinux2023DefaultPatchBaseline"
  operating_system = "AMAZON_LINUX_2023"
}

resource "aws_ssm_association" "patch_scan" {
  name = "AWS-RunPatchBaseline"

  association_name = "${var.project_name}-${var.environment}-patch-scan"

  targets {
    key    = "tag:Tier"
    values = ["Application"]
  }

  parameters = {
    Operation = "Scan"
  }

  schedule_expression = "cron(0 0 ? * SUN *)"

  apply_only_at_cron_interval = true
}
