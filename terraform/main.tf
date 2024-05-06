terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.66.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    null = {
      version = "3.2.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.31.0"
    }
  }
}

data "aws_secretsmanager_secret_version" "cloudflare_api_key" {
  secret_id = "arn:aws:secretsmanager:eu-central-1:211125442702:secret:infra-secrets-vdDGlS"
}

provider "cloudflare" {
  api_token = jsondecode(data.aws_secretsmanager_secret_version.cloudflare_api_key.secret_string)["cloudflare-api-token"]
}


terraform {
  backend "s3" {
    bucket         = "kplis-infrastructure"
    region         = "eu-central-1"
    key            = "tf-state"
    encrypt        = true
  }
}

variable "aws_region" {}
variable "aws_account_id" {}
