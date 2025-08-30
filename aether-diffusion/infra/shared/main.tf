# Shared configuration that can be used by both dev and prod environments
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Deploy to Google Cloud (if selected)
module "google_deployment" {
  count = var.cloud_provider == "google" ? 1 : 0
  
  source = "../modules/google"
  
  project_id            = var.google_project_id
  region               = local.region
  service_name         = local.service_name
  container_image      = var.container_image
  environment_variables = local.app_env_vars
  port                 = var.port
  memory               = local.final_config.memory
  cpu                  = local.final_config.cpu
  min_instances        = local.final_config.min_instances
  max_instances        = local.final_config.max_instances
  labels               = local.common_labels
  custom_domain        = var.custom_domain
  enable_monitoring    = var.enable_monitoring
  environment          = var.environment
}

# Deploy to Oracle Cloud (if selected)  
module "oracle_deployment" {
  count = var.cloud_provider == "oracle" ? 1 : 0
  
  source = "../modules/oracle"
  
  compartment_id       = var.oracle_compartment_id
  tenancy_id          = var.oracle_tenancy_id
  region              = local.region
  service_name        = local.service_name
  container_image     = var.container_image
  environment_variables = local.app_env_vars
  port                = var.port
  memory              = local.final_config.memory
  cpu                 = local.final_config.cpu
  min_instances       = local.final_config.min_instances
  max_instances       = local.final_config.max_instances
  labels              = local.common_labels
  custom_domain       = var.custom_domain
  enable_monitoring   = var.enable_monitoring
  environment         = var.environment
}