variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "mailgun_api_key" {
  description = "API Key for Mailgun"
  sensitive   = true
}

variable "mailgun_domain" {
  description = "Email domain for Mailgun"
  sensitive   = true
}

variable "git_commit" {
  description = "Latest git commit hash of this repository"
}

variable "recipients_list" {
  description = "A list of recipients that should receive the update"
  type        = list(string)
}
