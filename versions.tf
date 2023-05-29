terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
