# Prod environment outputs
output "service_url" {
  description = "URL of the deployed service"
  value       = module.shared_config.service_url
}

output "service_name" {
  description = "Name of the deployed service"
  value       = module.shared_config.service_name
}

output "environment" {
  description = "Environment name"
  value       = module.shared_config.environment
}

output "cloud_provider" {
  description = "Cloud provider used"
  value       = module.shared_config.cloud_provider
}

output "region" {
  description = "Deployment region"
  value       = module.shared_config.region
}

output "container_image" {
  description = "Container image deployed"
  value       = module.shared_config.container_image
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = module.shared_config.health_check_url
}

output "monitoring_dashboard" {
  description = "Monitoring dashboard URL"
  value       = module.shared_config.monitoring_dashboard
}

output "logs_url" {
  description = "Logs URL"
  value       = module.shared_config.logs_url
}