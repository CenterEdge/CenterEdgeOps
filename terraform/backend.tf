# State
terraform {
  required_version="0.11.14"

  backend "s3" {
    region         = "us-east-1"
    bucket         = "centeredgeterraform"
    key            = "Ops/terraform.tfstate"
    role_arn       = "arn:aws:iam::243399810067:role/TerraformDeployment"
    encrypt        = true
    dynamodb_table = "TerraformDeployment"
  }
}

# Remote State
data "terraform_remote_state" "opsroot" {
  backend = "s3"
  config {
    region         = "us-east-1"
    bucket         = "centeredgeterraform"
    key            = "OpsRoot/terraform.tfstate"
    role_arn       = "arn:aws:iam::243399810067:role/TerraformDeployment"
    encrypt        = true
    dynamodb_table = "TerraformDeployment"
  }
}

# Identity running terraform
data "aws_caller_identity" "current" {}
