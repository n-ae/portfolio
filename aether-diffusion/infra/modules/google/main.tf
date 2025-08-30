# Google Cloud Run deployment module
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Enable required APIs
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
  
  disable_dependent_services = true
  disable_on_destroy        = false
}

resource "google_project_service" "container_registry" {
  service = "containerregistry.googleapis.com"
  
  disable_dependent_services = true  
  disable_on_destroy        = false
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  
  disable_dependent_services = true
  disable_on_destroy        = false
}

# Cloud Run service
resource "google_cloud_run_service" "main" {
  name     = var.service_name
  location = var.region

  template {
    metadata {
      labels = var.labels
      annotations = {
        "autoscaling.knative.dev/minScale" = tostring(var.min_instances)
        "autoscaling.knative.dev/maxScale" = tostring(var.max_instances)
        "run.googleapis.com/cpu-throttling" = var.environment == "prod" ? "false" : "true"
      }
    }

    spec {
      container_concurrency = var.concurrency
      timeout_seconds      = var.timeout
      service_account_name = google_service_account.cloudrun_sa.email

      containers {
        image = var.container_image
        
        ports {
          container_port = var.port
        }

        resources {
          limits = {
            memory = var.memory
            cpu    = var.cpu
          }
        }

        # Environment variables
        dynamic "env" {
          for_each = var.environment_variables
          content {
            name  = env.key
            value = env.value
          }
        }

        # Startup probe
        startup_probe {
          http_get {
            path = "/health"
            port = var.port
          }
          initial_delay_seconds = 10
          timeout_seconds      = 5
          period_seconds       = 10
          failure_threshold    = 3
        }

        # Liveness probe
        liveness_probe {
          http_get {
            path = "/health"
            port = var.port
          }
          initial_delay_seconds = 30
          timeout_seconds      = 5
          period_seconds       = 30
          failure_threshold    = 3
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.run_api,
    google_project_service.container_registry
  ]

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }
}

# Service Account for Cloud Run
resource "google_service_account" "cloudrun_sa" {
  account_id   = "${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
  description  = "Service account for Cloud Run service ${var.service_name}"
}

# IAM policy for unauthenticated access
resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.main.location
  project  = google_cloud_run_service.main.project
  service  = google_cloud_run_service.main.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Custom domain mapping (if specified)
resource "google_cloud_run_domain_mapping" "main" {
  count = var.custom_domain != "" ? 1 : 0

  location = var.region
  name     = var.custom_domain

  metadata {
    namespace = var.project_id
    labels    = var.labels
  }

  spec {
    route_name = google_cloud_run_service.main.name
  }
}

# Monitoring alert policy (if enabled)
resource "google_monitoring_alert_policy" "high_error_rate" {
  count = var.enable_monitoring ? 1 : 0

  display_name = "${var.service_name} - High Error Rate"
  combiner     = "OR"
  
  conditions {
    display_name = "Error rate > 5%"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" resource.label.service_name=\"${var.service_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 0.05
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = ["resource.label.service_name"]
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" # 7 days
  }

  notification_channels = []

  documentation {
    content = "Error rate for ${var.service_name} is above 5%"
  }
}

# Monitoring alert for high latency
resource "google_monitoring_alert_policy" "high_latency" {
  count = var.enable_monitoring ? 1 : 0

  display_name = "${var.service_name} - High Latency"
  combiner     = "OR"
  
  conditions {
    display_name = "95th percentile latency > 2 seconds"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" resource.label.service_name=\"${var.service_name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GREATER_THAN"
      threshold_value = 2000
      
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_PERCENTILE_95"
        group_by_fields     = ["resource.label.service_name"]
      }
    }
  }

  alert_strategy {
    auto_close = "604800s" # 7 days
  }

  notification_channels = []

  documentation {
    content = "95th percentile latency for ${var.service_name} is above 2 seconds"
  }
}