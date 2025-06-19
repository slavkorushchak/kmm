#!/bin/bash

# Setup GCP Service Account for GitHub Actions
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

print_header "🔐 Setup GCP Service Account for GitHub Actions"

# Load existing configuration
if [ -f "gcp-config.env" ]; then
    source gcp-config.env
    print_status "Loaded configuration from gcp-config.env"
else
    print_error "Please run ./setup-gcp.sh first to create basic GCP configuration"
    exit 1
fi

# Set the project
gcloud config set project $PROJECT_ID

# Create service account
SERVICE_ACCOUNT_NAME="github-actions-deployer"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

print_header "📋 Step 1: Create Service Account"

print_status "Creating service account: $SERVICE_ACCOUNT_NAME"
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions Deployer" \
    --description="Service account for GitHub Actions to deploy to Cloud Run" || print_warning "Service account might already exist"

print_header "🔑 Step 2: Grant Required Permissions"

# Required roles for Cloud Run deployment
REQUIRED_ROLES=(
    "roles/run.admin"
    "roles/storage.admin"
    "roles/artifactregistry.writer"
    "roles/iam.serviceAccountUser"
)

for role in "${REQUIRED_ROLES[@]}"; do
    print_status "Granting role: $role"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$role"
done

print_header "🔐 Step 3: Create Service Account Key"

KEY_FILE="github-actions-key.json"
print_status "Creating service account key: $KEY_FILE"

gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

print_header "🔧 Step 4: Configure Docker Authentication"

# Configure Docker for Artifact Registry
print_status "Configuring Docker authentication..."
gcloud auth configure-docker $REGION-docker.pkg.dev

print_header "✅ Setup Complete!"

echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Add these secrets to your GitHub repository:"
echo "   Go to: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/settings/secrets/actions"
echo ""
echo "   Add the following secrets:"
echo "   • GCP_PROJECT_ID = $PROJECT_ID"
echo "   • GCP_REGION = $REGION"
echo "   • GCP_REPOSITORY = $REPOSITORY"

# Read the service account key and encode it
if [ -f "$KEY_FILE" ]; then
    print_status "Service account key contents (copy this to GCP_SA_KEY secret):"
    echo ""
    echo "   • GCP_SA_KEY = $(cat $KEY_FILE | base64 -w 0 2>/dev/null || cat $KEY_FILE | base64)"
    echo ""
    print_warning "⚠️  IMPORTANT: Keep this key secure and delete the local file after adding to GitHub secrets!"
    echo ""
    read -p "Press Enter after adding secrets to GitHub, then I'll clean up the key file..."
    rm -f $KEY_FILE
    print_status "Local key file deleted for security"
fi

echo ""
echo "2. Your GitHub Actions will now automatically deploy to:"
echo "   • Project: $PROJECT_ID"
echo "   • Region: $REGION" 
echo "   • Registry: $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY"
echo ""
echo "🚀 Push to main branch to trigger automated deployment!" 