terraform {
  required_version = "~> 0.12.0"

  required_providers {
    aws     = "~> 2.0"
    archive = "~> 1.3"
    local   = "~> 1.2"
    null    = "~> 2.0"
  }
}

provider "aws" {}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
