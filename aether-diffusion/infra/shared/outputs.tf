# Shared outputs across environments
output "service_url" {
  description = "URL of the deployed service"
  value       = var.cloud_provider == "google" ? module.google_deployment[0].service_url : module.oracle_deployment[0].service_url
}

output "service_name" {
  description = "Name of the deployed service"
  value       = "${var.project_name}-${var.environment}"
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "cloud_provider" {
  description = "Cloud provider used"
  value       = var.cloud_provider
}

output "region" {
  description = "Deployment region"
  value       = local.region
}

output "container_image" {
  description = "Container image deployed"
  value       = var.container_image
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "${var.cloud_provider == "google" ? module.google_deployment[0].service_url : module.oracle_deployment[0].service_url}/health"
}

output "monitoring_dashboard" {
  description = "Monitoring dashboard URL"
  value       = var.cloud_provider == "google" && var.enable_monitoring ? module.google_deployment[0].monitoring_dashboard : null
}

output "logs_url" {
  description = "Logs URL"
  value       = var.cloud_provider == "google" && var.enable_monitoring ? module.google_deployment[0].logs_url : null
}