# Shared variables across environments
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "yahoo-fantasy-api"
}

variable "cloud_provider" {
  description = "Cloud provider to deploy to (google or oracle)"
  type        = string
  default     = "google"
  validation {
    condition     = contains(["google", "oracle"], var.cloud_provider)
    error_message = "Cloud provider must be either 'google' or 'oracle'."
  }
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = ""
}

variable "container_image" {
  description = "Container image URL"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the application"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "memory" {
  description = "Memory allocation"
  type        = string
  default     = "256Mi"
}

variable "cpu" {
  description = "CPU allocation"
  type        = string
  default     = "1000m"
}

variable "timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

variable "port" {
  description = "Container port"
  type        = number
  default     = 8080
}

# Cloud-specific variables
variable "google_project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = ""
}

variable "oracle_compartment_id" {
  description = "Oracle Cloud compartment ID"
  type        = string
  default     = ""
}

variable "oracle_tenancy_id" {
  description = "Oracle Cloud tenancy ID"
  type        = string
  default     = ""
}

# Domain and SSL
variable "custom_domain" {
  description = "Custom domain for the service"
  type        = string
  default     = ""
}

variable "enable_ssl" {
  description = "Enable SSL certificate"
  type        = bool
  default     = true
}

# Monitoring and logging
variable "enable_monitoring" {
  description = "Enable monitoring and alerting"
  type        = bool
  default     = true
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

# Tags and labels
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}