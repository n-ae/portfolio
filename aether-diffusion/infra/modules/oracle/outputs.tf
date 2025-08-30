# Oracle Cloud module outputs
output "service_url" {
  description = "URL of the Load Balancer service"
  value       = "http://${oci_load_balancer_load_balancer.main.ip_addresses[0]}"
}

output "service_name" {
  description = "Name of the Container Instance service"
  value       = oci_container_instances_container_instance.main.display_name
}

output "service_id" {
  description = "ID of the Container Instance service"
  value       = oci_container_instances_container_instance.main.id
}

output "private_ip" {
  description = "Private IP of the container instance"
  value       = oci_container_instances_container_instance.main.vnics[0].private_ip
}

output "public_ip" {
  description = "Public IP of the load balancer"
  value       = oci_load_balancer_load_balancer.main.ip_addresses[0]
}

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = oci_load_balancer_load_balancer.main.id
}

output "vcn_id" {
  description = "ID of the VCN"
  value       = oci_core_vcn.main.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = oci_core_subnet.main.id
}

output "custom_domain_url" {
  description = "Custom domain URL if configured"
  value       = var.custom_domain != "" ? "http://${var.custom_domain}" : null
}

output "monitoring_dashboard" {
  description = "Monitoring dashboard URL"
  value       = var.enable_monitoring ? "https://cloud.oracle.com/monitoring/alarms?region=${var.region}&compartmentId=${var.compartment_id}" : null
}

output "logs_url" {
  description = "Logging URL for the service"
  value       = "https://cloud.oracle.com/logging/search?region=${var.region}&compartmentId=${var.compartment_id}"
}

output "container_console_url" {
  description = "URL to view container instance in the console"
  value       = "https://cloud.oracle.com/compute/container-instances/${oci_container_instances_container_instance.main.id}?region=${var.region}"
}

output "load_balancer_console_url" {
  description = "URL to view load balancer in the console"
  value       = "https://cloud.oracle.com/networking/load-balancers/${oci_load_balancer_load_balancer.main.id}?region=${var.region}"
}