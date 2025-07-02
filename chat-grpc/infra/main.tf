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
              # Update package lists
              sudo yum update -y

              # Install git
              sudo yum install -y git

              # Install Go (using a common method for Amazon Linux 2023)
              # For other AMIs, you might need a different installation method.
              sudo yum install -y golang

              # Install protobuf compiler and gRPC Go plugins
              # This assumes protoc is available via package manager or will be installed manually.
              # For Amazon Linux 2023, golang package includes protoc-gen-go and protoc-gen-go-grpc
              # If not, you might need to manually download and install protoc and the plugins.
              # Example for manual installation (uncomment if needed):
              PROTOBUF_VERSION="27.2"
              GRPC_GO_VERSION="1.64.0" # Check for latest compatible version

              # Install protoc
              curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$${PROTOBUF_VERSION}/protoc-$${PROTOBUF_VERSION}-linux-x86_64.zip
              sudo unzip protoc-$${PROTOBUF_VERSION}-linux-x86_64.zip -d /usr/local
              rm protoc-$${PROTOBUF_VERSION}-linux-x86_64.zip

              # Install Go gRPC plugins
              export PATH=$PATH:/usr/local/go/bin
              go install google.golang.org/protobuf/cmd/protoc-gen-go@v$${GRPC_GO_VERSION}
              go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v$${GRPC_GO_VERSION}
              sudo cp ~/go/bin/protoc-gen-go /usr/local/bin/
              sudo cp ~/go/bin/protoc-gen-go-grpc /usr/local/bin/

              # Clone your Go gRPC chat application repository
              # IMPORTANT: Replace with your actual public repository URL
              REPO_URL="${var.repo_url}"
              APP_DIR="chat-grpc" # The directory your repo clones into

              git clone $REPO_URL $APP_DIR
              cd $APP_DIR

              # Initialize Go modules and download dependencies
              # Ensure your go.mod file is correctly set up as per previous steps
              go mod tidy
              go get ./...

              # Generate protobuf Go files
              # This assumes chat.proto is in the root of your cloned repository
              # and the 'chat' directory is where the generated files should go.
              protoc --go_out=. --go-grpc_out=. chat.proto

              # Build the server application
              # Assuming your server.go is in the root of the cloned repo
              go build -o chat_server server.go

              # Run the server in the background using nohup
              # Output will be redirected to nohup.out
              nohup ./chat_server > nohup.out 2>&1 &

              echo "Go gRPC server setup complete and running."
              EOF

  tags = {
    Name = "grpc-chat-server"
  }
}
