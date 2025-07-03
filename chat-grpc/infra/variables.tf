# variables.tf
# This file defines the input variables for the Terraform configuration.

variable "region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "eu-west-1"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance (e.g., Amazon Linux 2023)."
  type        = string
  # Find latest Amazon Linux 2023 AMI for your region:
  # aws ec2 describe-images --owners amazon --filters "Name=name,Values=al2023-ami-*-kernel-6.1-x86_64" "Name=state,Values=available" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text
  # aws linux
  default = "ami-0803576f0c0169402"
  # debian 12 
  # default = "ami-0fbb72557598f5284"
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3a.nano"
}

variable "key_pair_name" {
  description = "The name of Key Pair for SSH access."
  type        = string
  # IMPORTANT: Replace with the actual name of your SSH key pair in AWS
  # Example: default = "my-ssh-key"
  default = "chat-grpc"
}

variable "grpc_port" {
  description = "The port on which the gRPC server will listen."
  type        = number
  default     = 50051
}

variable "repo_url" {
  description = "The URL of your public Git repository containing the Go chat application."
  type        = string
  # IMPORTANT: Replace with the actual URL of your public Git repository
  # Example: default = "https://github.com/your-username/go-chat-app.git"
  default = "https://github.com/n-ae/portfolio.git"
}
