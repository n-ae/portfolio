# Prod environment variables
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aether-diffusion"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cloud_provider" {
  description = "Cloud provider to use (google or oracle)"
  type        = string
  default     = "google"
  
  validation {
    condition     = contains(["google", "oracle"], var.cloud_provider)
    error_message = "Cloud provider must be either 'google' or 'oracle'."
  }
}

variable "region" {
  description = "Deployment region (cloud-specific)"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "ghcr.io/your-username/aether-diffusion:latest"
}

# Google Cloud specific variables
variable "google_project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = ""
}

# Oracle Cloud specific variables
variable "oracle_compartment_id" {
  description = "Oracle Cloud compartment OCID"
  type        = string
  default     = ""
}

variable "oracle_tenancy_id" {
  description = "Oracle Cloud tenancy OCID"
  type        = string
  default     = ""
}

# Application configuration
variable "port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
}

# Environment variables
variable "environment_variables" {
  description = "Additional environment variables"
  type        = map(string)
  default     = {}
  sensitive   = true
}

# Resource configuration (prod-specific defaults)
variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "memory" {
  description = "Memory allocation"
  type        = string
  default     = "512Mi"
}

variable "cpu" {
  description = "CPU allocation"
  type        = string
  default     = "2000m"
}

variable "custom_domain" {
  description = "Custom domain for the service"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags/labels"
  type        = map(string)
  default     = {
    owner = "platform-team"
  }
}