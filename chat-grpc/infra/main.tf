# main.tf
# This file defines the AWS resources for deploying the Go gRPC chat server on an EC2 instance.

# Configure the AWS provider
provider "aws" {
  region = var.region
}

# --- Networking Resources ---

# Create a new VPC
resource "aws_vpc" "grpc_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "g/rpc-chat-vpc"
  }
}

# Create a public subnet within the VPC
resource "aws_subnet" "grpc_subnet" {
  vpc_id                  = aws_vpc.grpc_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Assign a public IP to instances launched in this subnet
  availability_zone       = "${var.region}a" # Use the first AZ in the region
  tags = {
    Name = "grpc-chat-subnet"
  }
}

# Create an Internet Gateway to allow communication with the internet
resource "aws_internet_gateway" "grpc_igw" {
  vpc_id = aws_vpc.grpc_vpc.id
  tags = {
    Name = "grpc-chat-igw"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "grpc_route_table" {
  vpc_id = aws_vpc.grpc_vpc.id
  tags = {
    Name = "grpc-chat-route-table"
  }
}

# Add a route to the internet gateway
resource "aws_route" "grpc_internet_route" {
  route_table_id         = aws_route_table.grpc_route_table.id
  destination_cidr_block = "0.0.0.0/0" # Route all outbound traffic to the internet
  gateway_id             = aws_internet_gateway.grpc_igw.id
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "grpc_subnet_association" {
  subnet_id      = aws_subnet.grpc_subnet.id
  route_table_id = aws_route_table.grpc_route_table.id
}

# --- Security Group for the gRPC Server ---

# Create a security group to allow inbound traffic for SSH and gRPC
resource "aws_security_group" "grpc_server_sg" {
  vpc_id      = aws_vpc.grpc_vpc.id
  name        = "grpc-chat-server-sg"
  description = "Allow SSH and gRPC inbound traffic"

  # Inbound rule for SSH (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  # Inbound rule for gRPC (port 50051, or whatever var.grpc_port is set to) from anywhere
  ingress {
    from_port   = var.grpc_port
    to_port     = var.grpc_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow gRPC traffic"
  }

  # Outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "grpc-chat-server-sg"
  }
}

# --- SSH Key Pair Generation ---
# This resource generates a new RSA key pair and registers its public key with AWS.
resource "tls_private_key" "grpc_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "grpc_generated_key" {
  key_name   = "grpc-chat-key-${random_string.suffix.result}" # Unique name for the key pair
  public_key = tls_private_key.grpc_ssh_key.public_key_openssh
}

# A random string to ensure unique key pair names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# --- EC2 Instance for the gRPC Server ---

resource "aws_instance" "grpc_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.grpc_generated_key.key_name # Use the newly generated key pair
  subnet_id     = aws_subnet.grpc_subnet.id
  vpc_security_group_ids = [aws_security_group.grpc_server_sg.id]

  # User data script to set up and run the Go gRPC server
  user_data = <<-EOF
              #!/bin/bash

              # Define a log file for all script output
              LOG_FILE="/var/log/grpc_server_setup.log"
              # Redirect all stdout and stderr to the log file, and also to console (tee)
              exec > >(tee -a $${LOG_FILE}) 2>&1

              echo "Starting gRPC server setup at $(date)"

              # Update package lists and upgrade existing packages
              # sudo apt-get update -y
              # sudo apt-get upgrade -y

              # Install git
              # sudo apt-get install -y git

              # Install Go
              # sudo apt-get install -y golang


              # Update package lists
              sudo yum update -y

              # Install git
              sudo yum install -y git

              # Install Go
              sudo yum install -y golang


              # --- Install protobuf compiler globally (as root) ---
              PROTOBUF_VERSION="27.2"
              # Detect architecture for correct protobuf binary download
              ARCH=$(uname -m)
              PROTOBUF_ARCH=""
              if [ "$ARCH" = "x86_64" ]; then
                  PROTOBUF_ARCH="linux-x86_64"
              elif [ "$ARCH" = "aarch64" ]; then
                  PROTOBUF_ARCH="linux-aarch_64"
              else
                  echo "Unsupported architecture: $ARCH"
                  exit 1
              fi

              curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOBUF_VERSION/protoc-$PROTOBUF_VERSION-$PROTOBUF_ARCH.zip
              sudo unzip protoc-$PROTOBUF_VERSION-$PROTOBUF_ARCH.zip -d /usr/local
              rm protoc-$PROTOBUF_VERSION-$PROTOBUF_ARCH.zip
              # Ensure protoc executable is in PATH for later use
              export PATH=$PATH:/usr/local/bin

              # --- Switch to ec2-user for Go-specific commands ---
              sudo -u ${local.username} bash -c '
                  echo "Running Go-specific setup as ec2-user..."

                  # Change to ec2-user home directory where they have write permissions

                  cd ~

                  # Set up Go environment for ec2-user session
                  export GOPATH=/home/${local.username}/go
                  export PATH=$PATH:/usr/bin:/usr/local/bin:$GOPATH/bin
                  # mkdir -p $GOPATH/bin $GOPATH/src

                  # Explicitly set GOPROXY to ensure module downloads work
                  export GOPROXY=https://proxy.golang.org
                  # Explicitly set GOSUMDB to ensure module checksum verification works
                  export GOSUMDB=sum.golang.org

                  go version

                  # Clone your Go gRPC chat application repository
                  # IMPORTANT: Replace with your actual public repository URL
                  REPO_URL="${var.repo_url}"
                  APP_DIR="chat-grpc" # The directory your repo clones into

                  # Clone directly into the APP_DIR, assuming the repo structure allows this.
                  # If your repo is 'my-portfolio.git' and the Go app is in 'my-portfolio/chat-grpc',
                  # you might need to adjust this.
                  git clone --depth 1 $REPO_URL temp
                  mv temp/$APP_DIR $APP_DIR
                  rm -rf temp
                  cd $APP_DIR

                  rm -rf go.mod go.sum
                  go mod init chat-grpc

                  pwd
                  ls -la

                  # Initialize Go modules and download dependencies
                  go mod tidy

                  # Install Go gRPC plugins
                  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
                  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

                  # Generate protobuf Go files (protoc should now find the plugins)
                  protoc --go_out=. --go-grpc_out=. chat.proto

                  # Build the server application
                  go build -o chat_server server.go

                  # Run the server in the background using nohup
                  # Output will be redirected to nohup.out in the current directory (/home/ec2-user/chat-grpc)
                  nohup ./chat_server > nohup.out 2>&1 &

                  echo "Go gRPC server application started by ec2-user."
              ' # End of sudo -u ec2-user block

              echo "Go gRPC server setup complete and running. Application logs are in /home/ec2-user/chat-grpc/nohup.out."
              echo "Script execution logs are in $${LOG_FILE}"

              # --- Persist Go Environment for future ec2-user SSH sessions ---
              # Add Go environment variables to a profile script for ec2-user
              echo 'export GOPATH=/home/${local.username}/go' | sudo tee /etc/profile.d/go-env.sh
              echo 'export PATH=$PATH:/usr/bin:/usr/local/bin:/home/${local.username}/go/bin' | sudo tee -a /etc/profile.d/go-env.sh
              echo 'Go environment variables persisted for ec2-user.'
              EOF
  tags = {
    Name = "grpc-chat-server"
  }
}


resource "local_file" "private_key" {
    content  = tls_private_key.grpc_ssh_key.private_key_pem
    filename = "chat-grpc.private.pem"
}
