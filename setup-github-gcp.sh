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

# Extract repository info from git
REPO_INFO=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')
SECRETS_URL="https://github.com/$REPO_INFO/settings/secrets/actions"

echo ""
print_header "📋 Next Steps: Add GitHub Repository Secrets"
echo ""
print_status "🔗 Open this URL in your browser:"
echo "   $SECRETS_URL"
echo ""
print_status "📝 Click 'New repository secret' and add each of the following:"
echo ""

# Create a formatted secrets file for easy copying
SECRETS_FILE="github-secrets.txt"
cat > $SECRETS_FILE << EOF
=================================================
GitHub Repository Secrets - Copy & Paste Ready
=================================================

1. Secret Name: GCP_PROJECT_ID
   Secret Value: $PROJECT_ID

2. Secret Name: GCP_REGION  
   Secret Value: $REGION

3. Secret Name: GCP_REPOSITORY
   Secret Value: $REPOSITORY

EOF

# Read the service account key and encode it
if [ -f "$KEY_FILE" ]; then
    ENCODED_KEY=$(cat $KEY_FILE | base64 -w 0 2>/dev/null || cat $KEY_FILE | base64)
    cat >> $SECRETS_FILE << EOF
4. Secret Name: GCP_SA_KEY
   Secret Value: $ENCODED_KEY

EOF
fi

cat >> $SECRETS_FILE << EOF
=================================================
Deployment Information
=================================================
Your app will deploy to:
• Project: $PROJECT_ID
• Region: $REGION
• Registry: $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY

After adding secrets, push to main branch to trigger deployment!
=================================================
EOF

# Display the secrets with nice formatting
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 1. GCP_PROJECT_ID                                           │"
echo "└─────────────────────────────────────────────────────────────┘"
echo "$PROJECT_ID"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 2. GCP_REGION                                               │"
echo "└─────────────────────────────────────────────────────────────┘"
echo "$REGION"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 3. GCP_REPOSITORY                                           │"
echo "└─────────────────────────────────────────────────────────────┘"
echo "$REPOSITORY"
echo ""

if [ -f "$KEY_FILE" ]; then
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ 4. GCP_SA_KEY                                               │"
    echo "└─────────────────────────────────────────────────────────────┘"
    ENCODED_KEY=$(cat $KEY_FILE | base64 -w 0 2>/dev/null || cat $KEY_FILE | base64)
    echo "$ENCODED_KEY"
    echo ""
fi

print_status "💾 All secrets saved to: $SECRETS_FILE"
print_warning "⚠️  This file contains sensitive information!"
echo ""

echo "🔄 Instructions:"
echo "1. Open: $SECRETS_URL"
echo "2. For each secret above:"
echo "   • Click 'New repository secret'"
echo "   • Copy the name (e.g., GCP_PROJECT_ID)"
echo "   • Copy the value and paste it"
echo "   • Click 'Add secret'"
echo "3. Repeat for all 4 secrets"
echo ""

read -p "Press Enter after adding ALL secrets to GitHub..."

# Clean up sensitive files
if [ -f "$KEY_FILE" ]; then
    rm -f $KEY_FILE
    print_status "🗑️  Service account key file deleted for security"
fi

# Ask if user wants to keep the secrets file
echo ""
read -p "Delete the secrets file ($SECRETS_FILE) for security? [Y/n]: " DELETE_SECRETS
if [[ $DELETE_SECRETS =~ ^[Nn]$ ]]; then
    print_warning "⚠️  Remember to delete $SECRETS_FILE manually after use!"
else
    rm -f $SECRETS_FILE
    print_status "🗑️  Secrets file deleted for security"
fi

echo ""
print_header "🚀 Ready for Automated Deployment!"
echo ""
echo "Your GitHub Actions will now automatically deploy to:"
echo "   • Project: $PROJECT_ID"
echo "   • Region: $REGION" 
echo "   • Registry: $REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY"
echo ""
echo "🎯 Push to main branch to trigger automated deployment!"
echo "📊 Monitor deployment: https://github.com/$REPO_INFO/actions" 