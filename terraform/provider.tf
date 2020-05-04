provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::833738481970:role/Deployer"
  }

  version = "~> 2.52"
}

provider "local" {
  version = "~> 1.3"
}

