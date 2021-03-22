variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile name"
}

variable "mailgun_api_key" {
  description = "API Key for Mailgun"
}

variable "mailgun_domain" {
  description = "Email domain for Mailgun"
}

variable "git_commit" {
  description = "Latest git commit hash of this repository"
}
