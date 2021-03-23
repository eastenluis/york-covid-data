#!/bin/bash

# Fail fast
set -u ; set -e

BUILD_PATH="$(dirname "$0")/.."

# Arguments
aws_ecr_repository_url=$1
build_number=$2
aws_region=$3
aws_profile=$4
aws_account_id=$(aws sts get-caller-identity --profile $aws_profile --query Account --output text)

# Login the AWS ECR Repository
aws ecr get-login-password --region $aws_region --profile $aws_profile | docker login --username AWS --password-stdin $aws_account_id.dkr.ecr.$aws_region.amazonaws.com
echo "Docker login ECR with profile: $aws_profile and region: $aws_region"

echo "Building $aws_ecr_repository_url:$build_number..."
# Build Image
docker build $BUILD_PATH --tag "$aws_ecr_repository_url:$build_number" --tag "$aws_ecr_repository_url:latest"

# Push the Image
docker push $aws_ecr_repository_url:$build_number
docker push $aws_ecr_repository_url:latest