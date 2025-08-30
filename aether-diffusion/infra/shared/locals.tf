# Shared local values
locals {
  # Common labels/tags
  common_labels = merge({
    project     = var.project_name
    environment = var.environment
    managed_by  = "opentofu"
    service     = "yahoo-fantasy-api"
  }, var.tags)

  # Service name
  service_name = "${var.project_name}-${var.environment}"

  # Region mapping between clouds
  region = var.region != "" ? var.region : (
    var.cloud_provider == "google" ? "us-central1" : 
    var.cloud_provider == "oracle" ? "us-ashburn-1" : 
    "us-central1"
  )

  # Environment-specific scaling
  scaling_config = {
    dev = {
      min_instances = 0
      max_instances = 3
      memory        = "256Mi"
      cpu          = "1000m"
    }
    prod = {
      min_instances = 1
      max_instances = 100
      memory        = "512Mi" 
      cpu          = "2000m"
    }
  }

  # Get scaling config for current environment
  current_scaling = lookup(local.scaling_config, var.environment, local.scaling_config.dev)

  # Final resource configuration
  final_config = {
    min_instances = var.min_instances != 0 ? var.min_instances : local.current_scaling.min_instances
    max_instances = var.max_instances != 10 ? var.max_instances : local.current_scaling.max_instances
    memory        = var.memory != "256Mi" ? var.memory : local.current_scaling.memory
    cpu          = var.cpu != "1000m" ? var.cpu : local.current_scaling.cpu
  }

  # Environment variables with defaults
  app_env_vars = merge({
    ENVIRONMENT = var.environment
    LOG_LEVEL   = var.log_level
    PORT        = tostring(var.port)
  }, var.environment_variables)

  # Cloud-specific configuration
  google_config = {
    project_id = var.google_project_id
    region     = local.region
  }

  oracle_config = {
    compartment_id = var.oracle_compartment_id
    tenancy_id     = var.oracle_tenancy_id
    region         = local.region
  }
}