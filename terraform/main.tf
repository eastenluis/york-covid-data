resource "aws_ecr_repository" "repo" {
  name                 = "york-covid-notifier"
  image_tag_mutability = "MUTABLE"
}

# Build and push the Docker image when the git_commit SHA changes
resource "null_resource" "push_image_to_ecr" {
  triggers = {
    git_commit = var.git_commit
  }

  provisioner "local-exec" {
    command     = "${path.module}/build.sh ${aws_ecr_repository.repo.repository_url} ${var.git_commit} ${var.aws_region} ${var.aws_profile}"
    interpreter = ["bash", "-c"]
  }
}

resource "aws_lambda_function" "notifier" {
  function_name = "york-covid-notifier"
  role          = aws_iam_role.lambda_exec.arn

  image_uri    = "${aws_ecr_repository.repo.repository_url}:${var.git_commit}"
  package_type = "Image"
  timeout = 90
  depends_on = [
    aws_ecr_repository.repo, null_resource.push_image_to_ecr
  ]

  environment {
    variables = {
      "MAILGUN_API_KEY"      = var.mailgun_api_key
      "MAILGUN_EMAIL_DOMAIN" = var.mailgun_domain
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "york-covid-notifier-lambda-exec"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
