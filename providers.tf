terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-2"
}

provider "github" {
  token = var.github_token
}