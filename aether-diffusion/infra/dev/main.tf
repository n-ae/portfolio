# Dev environment configuration
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

# Configure Google Cloud provider (if using Google)
provider "google" {
  count = var.cloud_provider == "google" ? 1 : 0
  
  project = var.google_project_id
  region  = local.region
}

# Configure Oracle Cloud provider (if using Oracle)
provider "oci" {
  count = var.cloud_provider == "oracle" ? 1 : 0
  
  tenancy_ocid     = var.oracle_tenancy_id
  region           = local.region
}

# Use shared configuration module
module "shared_config" {
  source = "../shared"
  
  # Pass through all variables
  project_name             = var.project_name
  environment             = var.environment
  cloud_provider          = var.cloud_provider
  region                  = var.region
  container_image         = var.container_image
  google_project_id       = var.google_project_id
  oracle_compartment_id   = var.oracle_compartment_id
  oracle_tenancy_id       = var.oracle_tenancy_id
  port                    = var.port
  log_level               = var.log_level
  environment_variables   = var.environment_variables
  min_instances          = var.min_instances
  max_instances          = var.max_instances
  memory                 = var.memory
  cpu                    = var.cpu
  custom_domain          = var.custom_domain
  enable_monitoring      = var.enable_monitoring
  tags                   = var.tags
}