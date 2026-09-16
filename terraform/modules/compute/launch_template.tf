resource "aws_launch_template" "application" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = local.ec2_baseline.ami_id
  instance_type = local.ec2_baseline.instance_type

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = local.ec2_baseline.associate_public_ip_address
    security_groups             = [var.application_security_group_id]
    delete_on_termination       = true
  }

  metadata_options {
    http_endpoint               = local.ec2_baseline.metadata_options.http_endpoint
    http_tokens                 = local.ec2_baseline.metadata_options.http_tokens
    http_put_response_hop_limit = local.ec2_baseline.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = local.ec2_baseline.metadata_options.instance_metadata_tags
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = local.ec2_baseline.root_block_device.encrypted
      volume_type           = local.ec2_baseline.root_block_device.volume_type
      volume_size           = local.ec2_baseline.root_block_device.volume_size
      delete_on_termination = local.ec2_baseline.root_block_device.delete_on_termination
    }
  }

  monitoring {
    enabled = local.ec2_baseline.monitoring
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}-application"
      Environment = var.environment
      Tier        = "Application"
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-${var.environment}-application"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Backup      = "DLM"
    }
  }

  update_default_version = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-application-launch-template"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
