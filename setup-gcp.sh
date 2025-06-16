#!/bin/bash

# GCP Setup Script for KMM App
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_header "🚀 GCP Setup for KMM App"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first:"
    echo "  brew install --cask google-cloud-sdk"
    exit 1
fi

# Step 1: Initialize gcloud and authenticate
print_header "🔑 Step 1: Authentication"
print_status "Initializing gcloud and setting up authentication..."

gcloud auth login
gcloud config set core/disable_usage_reporting true

# Step 2: Create or select project
print_header "📦 Step 2: Project Setup"

read -p "Enter your GCP Project ID (or press Enter to create new): " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    # Generate a unique project ID
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    PROJECT_ID="kmm-app-$TIMESTAMP"
    
    print_status "Creating new project: $PROJECT_ID"
    gcloud projects create $PROJECT_ID --name="KMM App"
    
    # Set billing account (user will need to do this manually)
    print_warning "Please set up billing for your project at:"
    echo "  https://console.cloud.google.com/billing/projects/$PROJECT_ID"
    read -p "Press Enter after setting up billing..."
else
    print_status "Using existing project: $PROJECT_ID"
fi

# Set the project
gcloud config set project $PROJECT_ID

# Step 3: Enable required APIs
print_header "🔧 Step 3: Enable Required Services"

REQUIRED_SERVICES=(
    "cloudbuild.googleapis.com"
    "run.googleapis.com"
    "containerregistry.googleapis.com"
    "artifactregistry.googleapis.com"
)

for service in "${REQUIRED_SERVICES[@]}"; do
    print_status "Enabling $service..."
    gcloud services enable $service
done

# Step 4: Create Artifact Registry repository (recommended over Container Registry)
print_header "📚 Step 4: Setup Artifact Registry"

REGION="us-central1"
REPOSITORY="kmm-images"

print_status "Creating Artifact Registry repository..."
gcloud artifacts repositories create $REPOSITORY \
    --repository-format=docker \
    --location=$REGION \
    --description="KMM App Docker images" || print_warning "Repository might already exist"

# Configure Docker authentication
print_status "Configuring Docker authentication..."
gcloud auth configure-docker $REGION-docker.pkg.dev

# Step 5: Set default region
gcloud config set run/region $REGION

print_header "✅ Setup Complete!"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Repository: $REPOSITORY"
echo ""
echo "Next steps:"
echo "1. Run: ./deploy-to-gcp.sh"
echo "2. Or follow the manual deployment steps"

# Save configuration for deployment script
cat > gcp-config.env << EOF
PROJECT_ID=$PROJECT_ID
REGION=$REGION
REPOSITORY=$REPOSITORY
EOF

print_status "Configuration saved to gcp-config.env" 