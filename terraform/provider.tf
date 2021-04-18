terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "paperwhale"

    workspaces {
      name = "york-covid-notifier"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}
