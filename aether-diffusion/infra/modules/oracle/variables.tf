# Oracle Cloud module variables
variable "compartment_id" {
  description = "Oracle Cloud compartment OCID"
  type        = string
}

variable "tenancy_id" {
  description = "Oracle Cloud tenancy OCID"
  type        = string
}

variable "region" {
  description = "Oracle Cloud region"
  type        = string
  default     = "us-ashburn-1"
}

variable "service_name" {
  description = "Name of the Container Instance service"
  type        = string
}

variable "container_image" {
  description = "Container image URL"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "port" {
  description = "Port that the container listens on"
  type        = number
  default     = 8080
}

variable "memory" {
  description = "Memory allocation for the container in GB"
  type        = string
  default     = "0.25"
}

variable "cpu" {
  description = "CPU allocation for the container (OCPU)"
  type        = string
  default     = "0.125"
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

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
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

variable "environment" {
  description = "Environment name"
  type        = string
}