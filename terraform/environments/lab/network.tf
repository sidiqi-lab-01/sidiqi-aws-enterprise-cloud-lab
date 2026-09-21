module "network" {
  source = "../../modules/network"

  project_name            = var.project_name
  environment             = var.environment
  public_domain_name      = "sidiqilab.com"
  application_domain_name = "aws.sidiqilab.com"

  vpc_cidr = "10.0.0.0/16"

  public_subnets = {
    "1a" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }

    "1b" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }

  private_subnets = {
    "1a" = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
    }

    "1b" = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1b"
    }
  }
}
