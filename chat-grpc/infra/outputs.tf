# outputs.tf
# This file defines the output values after Terraform applies the configuration.

output "public_ip" {
  description = "The public IP address of the gRPC server EC2 instance."
  value       = aws_instance.grpc_server.public_ip
}

output "public_dns" {
  description = "The public DNS name of the gRPC server EC2 instance."
  value       = aws_instance.grpc_server.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance. Remember to save the private key to a .pem file and set permissions (chmod 400)."
  value       = "chmod 400 chat-grpc.private.pem && ssh -i chat-grpc.private.pem ec2-user@${aws_instance.grpc_server.public_ip}"
}

# output "private_key" {
#   description = "The private key for SSH access. SAVE THIS TO A FILE (e.g., grpc-chat-key.pem) AND SET PERMISSIONS (chmod 400)."
#   value       = tls_private_key.grpc_ssh_key.private_key_pem
#   sensitive   = true # Mark as sensitive to prevent it from being displayed in logs
# }
