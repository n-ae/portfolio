#!/bin/bash

# Deploy Yahoo Fantasy API to Google Cloud Run
# Requires: gcloud CLI installed and authenticated

set -e

# Configuration
PROJECT_ID="${PROJECT_ID:-}"
REGION="${REGION:-us-central1}"
SERVICE_NAME="${SERVICE_NAME:-yahoo-fantasy-api}"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo_info "Checking prerequisites..."
    
    # Check if gcloud is installed
    if ! command -v gcloud &> /dev/null; then
        echo_error "gcloud CLI is not installed"
        echo "Install from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check if authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -1 &> /dev/null; then
        echo_error "Not authenticated with gcloud"
        echo "Run: gcloud auth login"
        exit 1
    fi
    
    # Check if project is set
    if [[ -z "$PROJECT_ID" ]]; then
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
        if [[ -z "$PROJECT_ID" ]]; then
            echo_error "No GCP project set"
            echo "Set with: gcloud config set project YOUR_PROJECT_ID"
            echo "Or use: PROJECT_ID=your-project ./container/deploy-cloudrun.sh"
            exit 1
        fi
    fi
    
    echo_success "Prerequisites check passed"
    echo_info "Project ID: $PROJECT_ID"
    echo_info "Region: $REGION"
    echo_info "Service Name: $SERVICE_NAME"
}

# Enable required APIs
enable_apis() {
    echo_info "Enabling required Google Cloud APIs..."
    
    gcloud services enable run.googleapis.com --project="$PROJECT_ID"
    gcloud services enable cloudbuild.googleapis.com --project="$PROJECT_ID"
    gcloud services enable containerregistry.googleapis.com --project="$PROJECT_ID"
    
    echo_success "APIs enabled"
}

# Build and push container
build_and_push() {
    echo_info "Building container for Cloud Run..."
    
    # Change to project root
    cd "$(dirname "$(dirname "$(realpath "$0")")")"
    
    # Build the image for Cloud Run (linux/amd64)
    echo_info "Cross-compiling for linux/amd64..."
    zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux
    
    # Build container image
    echo_info "Building container image..."
    docker build -f container/Containerfile.simple -t "$IMAGE_NAME" .
    
    # Configure Docker to use gcloud as a credential helper
    gcloud auth configure-docker --quiet
    
    # Push to Google Container Registry
    echo_info "Pushing image to Google Container Registry..."
    docker push "$IMAGE_NAME"
    
    echo_success "Container built and pushed to $IMAGE_NAME"
}

# Deploy to Cloud Run
deploy_to_cloudrun() {
    echo_info "Deploying to Google Cloud Run..."
    
    # Check if .env file exists for environment variables
    ENV_VARS=""
    if [[ -f ".env" ]]; then
        echo_info "Loading environment variables from .env file..."
        
        # Parse .env file and create --set-env-vars format
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ $key =~ ^[[:space:]]*# ]] || [[ -z "$key" ]]; then
                continue
            fi
            
            # Remove surrounding quotes and whitespace
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed 's/^["'\'']*//; s/["'\'']*$//')
            
            if [[ -n "$key" && -n "$value" ]]; then
                if [[ -z "$ENV_VARS" ]]; then
                    ENV_VARS="$key=$value"
                else
                    ENV_VARS="$ENV_VARS,$key=$value"
                fi
            fi
        done < .env
    else
        echo_warning ".env file not found, using demo credentials"
        ENV_VARS="YAHOO_CONSUMER_KEY=demo_key,YAHOO_CONSUMER_SECRET=demo_secret"
    fi
    
    # Deploy to Cloud Run
    gcloud run deploy "$SERVICE_NAME" \
        --image "$IMAGE_NAME" \
        --platform managed \
        --region "$REGION" \
        --allow-unauthenticated \
        --set-env-vars "$ENV_VARS" \
        --memory 256Mi \
        --cpu 1 \
        --concurrency 80 \
        --timeout 300 \
        --max-instances 10 \
        --min-instances 0 \
        --project "$PROJECT_ID"
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
        --platform managed \
        --region "$REGION" \
        --project "$PROJECT_ID" \
        --format 'value(status.url)')
    
    echo_success "Deployment completed!"
    echo_info "Service URL: $SERVICE_URL"
    
    return 0
}

# Test the deployment
test_deployment() {
    echo_info "Testing the deployed service..."
    
    # Get service URL
    SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
        --platform managed \
        --region "$REGION" \
        --project "$PROJECT_ID" \
        --format 'value(status.url)' 2>/dev/null)
    
    if [[ -z "$SERVICE_URL" ]]; then
        echo_error "Could not get service URL"
        return 1
    fi
    
    echo_info "Service URL: $SERVICE_URL"
    
    # Test health endpoint
    echo_info "Testing health endpoint..."
    if curl -sf "$SERVICE_URL/health" > /dev/null; then
        echo_success "Health check passed"
        curl -s "$SERVICE_URL/health" | jq 2>/dev/null || curl -s "$SERVICE_URL/health"
    else
        echo_error "Health check failed"
        return 1
    fi
    
    echo ""
    echo_info "Testing status endpoint..."
    if curl -sf "$SERVICE_URL/status" > /dev/null; then
        echo_success "Status check passed"
        curl -s "$SERVICE_URL/status" | jq 2>/dev/null || curl -s "$SERVICE_URL/status"
    else
        echo_error "Status check failed"
        return 1
    fi
    
    echo ""
    echo_info "Testing demo endpoint..."
    if curl -sf "$SERVICE_URL/demo" > /dev/null; then
        echo_success "Demo check passed"
        curl -s "$SERVICE_URL/demo" | jq 2>/dev/null || curl -s "$SERVICE_URL/demo"
    else
        echo_error "Demo check failed"
        return 1
    fi
    
    echo ""
    echo_success "All tests passed! 🎉"
    echo_info "Your Yahoo Fantasy API is now running on Google Cloud Run"
    echo_info "Base URL: $SERVICE_URL"
    echo_info "Monthly cost: FREE (within 2M request limit)"
    
    return 0
}

# Show help
show_help() {
    cat << EOF
Deploy Yahoo Fantasy API to Google Cloud Run

Usage: $0 [command]

Commands:
    deploy    Full deployment (build, push, deploy, test)
    build     Build and push container only
    test      Test existing deployment
    help      Show this help

Prerequisites:
    - gcloud CLI installed and authenticated
    - Docker installed
    - Project ID set (gcloud config set project YOUR_PROJECT)

Environment Variables:
    PROJECT_ID      Google Cloud Project ID
    REGION          Deployment region (default: us-central1)
    SERVICE_NAME    Cloud Run service name (default: yahoo-fantasy-api)

Examples:
    $0 deploy                           # Full deployment
    PROJECT_ID=my-project $0 deploy     # Deploy to specific project
    REGION=us-east1 $0 deploy           # Deploy to different region

Cost: FREE for up to 2 million requests/month
EOF
}

# Main execution
main() {
    case "${1:-deploy}" in
        deploy)
            check_prerequisites
            enable_apis
            build_and_push
            deploy_to_cloudrun
            test_deployment
            ;;
        build)
            check_prerequisites
            enable_apis
            build_and_push
            ;;
        test)
            check_prerequisites
            test_deployment
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"