#!/bin/bash

# GCP Cloud Run Deployment Script for KMM App
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

print_header "🚀 Deploying KMM App to Google Cloud Run"

# Load configuration
if [ -f "gcp-config.env" ]; then
    source gcp-config.env
    print_status "Loaded configuration from gcp-config.env"
else
    print_error "Configuration file gcp-config.env not found!"
    print_status "Please run ./setup-gcp.sh first"
    exit 1
fi

# Verify Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Verify gcloud authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n 1 > /dev/null; then
    print_error "Not authenticated with gcloud. Please run 'gcloud auth login'"
    exit 1
fi

# Image names
BACKEND_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/kmm-backend"
FRONTEND_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/kmm-frontend"

print_header "🔨 Step 1: Building and Pushing Backend"

print_status "Building backend image..."
docker build --platform linux/amd64 -f Dockerfile.backend -t kmm-backend .

print_status "Tagging backend image..."
docker tag kmm-backend:latest $BACKEND_IMAGE:latest

print_status "Pushing backend image to Artifact Registry..."
docker push $BACKEND_IMAGE:latest

print_status "Deploying backend to Cloud Run..."
gcloud run deploy kmm-backend \
    --image $BACKEND_IMAGE:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8081 \
    --memory 1Gi \
    --cpu 1 \
    --max-instances 10 \
    --set-env-vars "NODE_ENV=production"

# Get backend URL
BACKEND_URL=$(gcloud run services describe kmm-backend --platform managed --region $REGION --format 'value(status.url)')
print_status "Backend deployed at: $BACKEND_URL"

print_header "🎨 Step 2: Building and Pushing Frontend"

print_status "Building frontend image with backend URL: $BACKEND_URL"
docker build --platform linux/amd64 --build-arg BACKEND_URL="$BACKEND_URL" -f Dockerfile.frontend -t kmm-frontend .

print_status "Tagging frontend image..."
docker tag kmm-frontend:latest $FRONTEND_IMAGE:latest

print_status "Pushing frontend image to Artifact Registry..."
docker push $FRONTEND_IMAGE:latest

print_status "Deploying frontend to Cloud Run..."
gcloud run deploy kmm-frontend \
    --image $FRONTEND_IMAGE:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --max-instances 10 \
    --set-env-vars "NODE_ENV=production,BACKEND_URL=$BACKEND_URL"

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe kmm-frontend --platform managed --region $REGION --format 'value(status.url)')

print_header "✅ Deployment Complete!"

echo ""
echo "🎉 Your KMM App has been deployed successfully!"
echo ""
echo "📱 Frontend URL: $FRONTEND_URL"
echo "🔧 Backend URL:  $BACKEND_URL"
echo ""
echo "🔍 Monitoring:"
echo "   - Logs: https://console.cloud.google.com/run/detail/$REGION/kmm-frontend/logs?project=$PROJECT_ID"
echo "   - Metrics: https://console.cloud.google.com/run/detail/$REGION/kmm-frontend/metrics?project=$PROJECT_ID"
echo ""
echo "🛠️  Next steps:"
echo "   - Test your application: $FRONTEND_URL"
echo "   - Set up custom domain: https://cloud.google.com/run/docs/mapping-custom-domains"
echo "   - Configure CI/CD: https://cloud.google.com/run/docs/continuous-deployment-with-cloud-build"
echo ""

# Save deployment info
cat > deployment-info.txt << EOF
KMM App Deployment Information
==============================
Deployment Date: $(date)
Project ID: $PROJECT_ID
Region: $REGION

URLs:
- Frontend: $FRONTEND_URL
- Backend: $BACKEND_URL

Images:
- Frontend: $FRONTEND_IMAGE:latest
- Backend: $BACKEND_IMAGE:latest

Useful Commands:
- View logs: gcloud run services logs read kmm-frontend --region $REGION
- Update service: gcloud run deploy kmm-frontend --image $FRONTEND_IMAGE:latest --region $REGION
- Delete services: gcloud run services delete kmm-frontend --region $REGION
EOF

print_status "Deployment info saved to deployment-info.txt" 