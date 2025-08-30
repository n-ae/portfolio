# Infrastructure as Code

This directory contains OpenTofu infrastructure configuration for deploying the aether-diffusion API service to either Google Cloud or Oracle Cloud.

## Structure

```
infra/
├── dev/              # Development environment
├── prod/             # Production environment  
├── shared/           # Shared configuration and locals
└── modules/
    ├── google/       # Google Cloud Run module
    └── oracle/       # Oracle Cloud Container Instances module
```

## Cloud Providers

### Google Cloud (Recommended)
- **Service**: Cloud Run (serverless containers)
- **Cost**: Free tier up to 2 million requests/month
- **Features**: Automatic scaling, built-in monitoring, HTTPS
- **Deployment**: Single container, managed service

### Oracle Cloud  
- **Service**: Container Instances + Load Balancer
- **Cost**: Always Free tier available
- **Features**: Virtual networking, flexible shapes
- **Deployment**: Container instance behind load balancer

## Usage

### Prerequisites

1. Install OpenTofu: https://opentofu.org/docs/intro/install/
2. Set up cloud provider authentication:

**For Google Cloud:**
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

**For Oracle Cloud:**
```bash
# Set environment variables or use OCI config file
export TF_VAR_oracle_tenancy_id="ocid1.tenancy.oc1..your-id"
export TF_VAR_oracle_compartment_id="ocid1.compartment.oc1..your-id"
```

### Deploy to Development

```bash
cd infra/dev

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Set cloud_provider = "google" or "oracle"
# Fill in required variables

# Initialize and deploy
tofu init
tofu plan
tofu apply
```

### Deploy to Production

```bash
cd infra/prod

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Enable monitoring, set production resources

# Initialize and deploy  
tofu init
tofu plan
tofu apply
```

### Switch Cloud Providers

To switch between cloud providers, simply change the `cloud_provider` variable in your `terraform.tfvars`:

```hcl
# For Google Cloud
cloud_provider = "google"
google_project_id = "your-project-id"

# For Oracle Cloud  
cloud_provider = "oracle"
oracle_compartment_id = "ocid1.compartment.oc1..your-id"
oracle_tenancy_id = "ocid1.tenancy.oc1..your-id"
```

Then run `tofu plan` and `tofu apply` to migrate.

## Configuration

### Environment-Specific Defaults

**Development:**
- Min instances: 0 (scale to zero)
- Max instances: 3
- Memory: 256Mi
- CPU: 1000m
- Monitoring: Disabled

**Production:**
- Min instances: 1 (always running)
- Max instances: 100  
- Memory: 512Mi
- CPU: 2000m
- Monitoring: Enabled

### Required Variables

- `container_image`: Your container image URL
- Cloud-specific project/compartment IDs
- `environment_variables`: API keys and secrets

### Optional Variables

- `custom_domain`: Custom domain name
- `region`: Override default region
- Resource limits (memory, CPU, scaling)

## Outputs

After deployment, you'll get:
- `service_url`: Public URL of your service
- `health_check_url`: Health check endpoint
- `monitoring_dashboard`: Monitoring URL (if enabled)
- `logs_url`: Logs URL

## Cost Optimization

Both cloud providers offer generous free tiers suitable for development and low-traffic production workloads:

- **Google Cloud Run**: 2M requests/month free
- **Oracle Cloud**: Always Free tier with 2 OCPUs

For minimal usage (≤1000 requests/month), both should remain within free tier limits.