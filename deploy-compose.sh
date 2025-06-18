#!/bin/bash

# GCP Deployment with Docker Compose Build
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

print_header "🚀 Deploying KMM App to GCP with Docker Compose"

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

# Image names
BACKEND_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/kmm-backend"
FRONTEND_IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/kmm-frontend"

print_header "🔨 Step 1: Build and Deploy Backend"

# Set environment variables for Docker Compose
export BACKEND_IMAGE
export NODE_ENV=production

print_status "Building backend with Docker Compose..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build backend

print_status "Pushing backend image..."
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

print_header "🎨 Step 2: Build and Deploy Frontend"

# Set environment variables for frontend build
export FRONTEND_IMAGE
export BACKEND_URL

print_status "Building frontend with Docker Compose and backend URL: $BACKEND_URL"
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build frontend

print_status "Pushing frontend image..."
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
echo "🎉 Your KMM App has been deployed successfully using Docker Compose!"
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
KMM App Deployment Information (Docker Compose)
===============================================
Deployment Date: $(date)
Project ID: $PROJECT_ID
Region: $REGION

URLs:
- Frontend: $FRONTEND_URL
- Backend: $BACKEND_URL

Images:
- Frontend: $FRONTEND_IMAGE:latest
- Backend: $BACKEND_IMAGE:latest

Build Method: Standard Docker Compose Pattern
- Base: docker-compose.yml
- Development: docker-compose.override.yml (auto-loaded)
- Production: docker-compose.prod.yml (explicit)
- Platform: linux/amd64
- Parallel Builds: Enabled

Useful Commands:
- Rebuild all: docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
- Rebuild frontend: docker-compose -f docker-compose.yml -f docker-compose.prod.yml build frontend
- Local development: docker-compose up (auto-loads override.yml)
- View logs: gcloud run services logs read kmm-frontend --region $REGION
- Update service: gcloud run deploy kmm-frontend --image $FRONTEND_IMAGE:latest --region $REGION
EOF

print_status "Deployment info saved to deployment-info.txt"

# Clean up build containers
print_status "Cleaning up build containers..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml down --remove-orphans 