locals {
  ec2_baseline = {
    ami_id                      = local.ami_id
    instance_type               = var.instance_type
    associate_public_ip_address = false

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "disabled"
    }

    root_block_device = {
      encrypted             = true
      volume_type           = "gp3"
      volume_size           = var.root_volume_size
      delete_on_termination = true
    }

    monitoring = true
  }
}
