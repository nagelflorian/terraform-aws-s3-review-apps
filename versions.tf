terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 1.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 2.0"
    }
  }
}

provider "aws" {}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
