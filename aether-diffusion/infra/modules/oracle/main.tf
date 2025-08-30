# Oracle Cloud Container Instances deployment module
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# VCN for Container Instances
resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_name}-vcn"
  cidr_block     = "10.0.0.0/16"
  
  freeform_tags = var.labels
}

# Internet Gateway
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.service_name}-igw"
  
  freeform_tags = var.labels
}

# Route Table
resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.service_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
  
  freeform_tags = var.labels
}

# Subnet
resource "oci_core_subnet" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.service_name}-subnet"
  cidr_block     = "10.0.1.0/24"
  route_table_id = oci_core_route_table.main.id
  
  freeform_tags = var.labels
}

# Security List
resource "oci_core_security_list" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.service_name}-sl"

  # Ingress rules
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    
    tcp_options {
      min = var.port
      max = var.port
    }
  }
  
  # Health check ingress
  ingress_security_rules {
    protocol  = "6" # TCP
    source    = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    
    tcp_options {
      min = var.port
      max = var.port
    }
  }

  # Egress rules
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  
  freeform_tags = var.labels
}

# Convert memory from Mi to GB
locals {
  memory_gb = tonumber(replace(var.memory, "Mi", "")) / 1024
  cpu_ocpu  = tonumber(replace(var.cpu, "m", "")) / 1000
}

# Container Instance Configuration
resource "oci_container_instances_container_instance" "main" {
  compartment_id      = var.compartment_id
  display_name        = var.service_name
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = "CI.Standard.E4.Flex"
  
  shape_config {
    memory_in_gbs = local.memory_gb
    ocpus         = local.cpu_ocpu
  }

  vnics {
    subnet_id              = oci_core_subnet.main.id
    assign_public_ip       = true
    display_name          = "${var.service_name}-vnic"
    skip_source_dest_check = false
  }

  containers {
    display_name = var.service_name
    image_url    = var.container_image
    
    # Environment variables
    dynamic "environment_variables" {
      for_each = var.environment_variables
      content {
        key   = environment_variables.key
        value = environment_variables.value
      }
    }
    
    # Health check
    health_checks {
      health_check_type = "HTTP"
      path             = "/health"
      port             = var.port
      initial_delay_in_seconds = 10
      interval_in_seconds     = 30
      failure_threshold       = 3
      success_threshold       = 1
      timeout_in_seconds      = 5
    }
    
    # Resource requirements
    resource_config {
      memory_limit_in_gbs = local.memory_gb
      vcpus_limit        = local.cpu_ocpu
    }
  }
  
  freeform_tags = var.labels
  
  graceful_shutdown_timeout_in_seconds = 30
  container_restart_policy            = "ALWAYS"
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_id
}

# Load Balancer for external access
resource "oci_load_balancer_load_balancer" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.service_name}-lb"
  shape          = "flexible"
  
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
  
  subnet_ids = [oci_core_subnet.main.id]
  
  is_private = false
  
  freeform_tags = var.labels
}

# Backend Set
resource "oci_load_balancer_backend_set" "main" {
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  name             = "${var.service_name}-backend"
  policy          = "ROUND_ROBIN"
  
  health_checker {
    protocol            = "HTTP"
    url_path           = "/health"
    port               = var.port
    return_code        = 200
    timeout_in_millis  = 5000
    interval_ms        = 30000
    retries            = 3
  }
}

# Backend
resource "oci_load_balancer_backend" "main" {
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  backendset_name  = oci_load_balancer_backend_set.main.name
  ip_address       = oci_container_instances_container_instance.main.vnics[0].private_ip
  port             = var.port
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Listener
resource "oci_load_balancer_listener" "main" {
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = "${var.service_name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.main.name
  port                     = 80
  protocol                 = "HTTP"
}

# Monitoring Alarm for high error rate (if enabled)
resource "oci_monitoring_alarm" "high_error_rate" {
  count           = var.enable_monitoring ? 1 : 0
  compartment_id  = var.compartment_id
  display_name    = "${var.service_name} - High Error Rate"
  metric_compartment_id = var.compartment_id
  
  query = "LoadBalancer[1m]{resourceDisplayName=\"${var.service_name}-lb\"}.ErrorRate.mean() > 0.05"
  
  severity = "WARNING"
  
  destinations = []
  
  enabled = true
  
  freeform_tags = var.labels
}

# Monitoring Alarm for high response time (if enabled)
resource "oci_monitoring_alarm" "high_response_time" {
  count           = var.enable_monitoring ? 1 : 0
  compartment_id  = var.compartment_id
  display_name    = "${var.service_name} - High Response Time"
  metric_compartment_id = var.compartment_id
  
  query = "LoadBalancer[1m]{resourceDisplayName=\"${var.service_name}-lb\"}.ResponseTime.mean() > 2000"
  
  severity = "WARNING"
  
  destinations = []
  
  enabled = true
  
  freeform_tags = var.labels
}