# Google Cloud module outputs
output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_service.main.status[0].url
}

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_service.main.name
}

output "service_id" {
  description = "ID of the Cloud Run service"
  value       = google_cloud_run_service.main.id
}

output "latest_revision" {
  description = "Latest revision of the service"
  value       = google_cloud_run_service.main.status[0].latest_ready_revision_name
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.cloudrun_sa.email
}

output "custom_domain_url" {
  description = "Custom domain URL if configured"
  value       = var.custom_domain != "" ? "https://${var.custom_domain}" : null
}

output "monitoring_dashboard" {
  description = "Monitoring dashboard URL"
  value       = var.enable_monitoring ? "https://console.cloud.google.com/monitoring/dashboards/custom?project=${var.project_id}&pageState=%7B%22dash%22:%7B%22f%22:%22${google_cloud_run_service.main.name}%22%7D%7D" : null
}

output "logs_url" {
  description = "Cloud Logging URL for the service"
  value       = "https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22${google_cloud_run_service.main.name}%22;timeRange=P1D?project=${var.project_id}"
}

output "revision_url" {
  description = "URL to view revisions in the console"
  value       = "https://console.cloud.google.com/run/detail/${var.region}/${google_cloud_run_service.main.name}/revisions?project=${var.project_id}"
}

output "metrics_url" {
  description = "URL to view metrics in the console"
  value       = "https://console.cloud.google.com/run/detail/${var.region}/${google_cloud_run_service.main.name}/metrics?project=${var.project_id}"
}