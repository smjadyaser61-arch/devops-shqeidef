terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

module "artifacts" {
  source = "../../modules/s3-bucket"

  bucket_name = "shipfast-artifacts-staging-${data.aws_caller_identity.current.account_id}"
  environment = "staging"
  cost_center = "shipfast-staging"
  owner       = "devops-team"
}

output "bucket_name" {
  value = module.artifacts.bucket_name
}

output "bucket_arn" {
  value = module.artifacts.bucket_arn
}
