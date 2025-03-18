# State
terraform {
  required_version = "~> 1.10.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.90.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
    bucket = "centeredgeterraform"
    key    = "Ops/terraform.tfstate"
    assume_role = {
      role_arn = "arn:aws:iam::243399810067:role/TerraformDeployment"
    }
    encrypt        = true
    dynamodb_table = "TerraformDeployment"
  }
}

# Remote State
data "terraform_remote_state" "opsroot" {
  backend = "s3"
  config = {
    region         = "us-east-1"
    bucket         = "centeredgeterraform"
    key            = "OpsRoot/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "TerraformDeployment"
    assume_role = {
      role_arn = "arn:aws:iam::243399810067:role/TerraformDeployment"
    }
  }
}

data "aws_caller_identity" "current" {
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::833738481970:role/Deployer"
  }
}

provider "local" {
}
