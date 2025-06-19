#!/bin/bash

# Validate GitHub Repository Secrets for GCP Deployment
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_header "🔍 GitHub Secrets Validation"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

# Extract repository info
REPO_INFO=$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/' 2>/dev/null)
if [ -z "$REPO_INFO" ]; then
    print_error "Could not determine GitHub repository from git remote"
    exit 1
fi

SECRETS_URL="https://github.com/$REPO_INFO/settings/secrets/actions"

echo "🔗 Repository: $REPO_INFO"
echo "📝 Secrets URL: $SECRETS_URL"
echo ""

# Check if GitHub CLI is available for validation
if command -v gh &> /dev/null; then
    print_status "GitHub CLI found - checking secrets..."
    echo ""
    
    # Required secrets
    REQUIRED_SECRETS=("GCP_PROJECT_ID" "GCP_REGION" "GCP_REPOSITORY" "GCP_SA_KEY")
    MISSING_SECRETS=()
    
    for secret in "${REQUIRED_SECRETS[@]}"; do
        if gh secret list | grep -q "^$secret"; then
            print_status "$secret is configured"
        else
            print_error "$secret is missing"
            MISSING_SECRETS+=("$secret")
        fi
    done
    
    if [ ${#MISSING_SECRETS[@]} -eq 0 ]; then
        echo ""
        print_header "🎉 All Secrets Configured!"
        echo "✅ Your repository is ready for automated deployment"
        echo "🚀 Push to main branch to trigger deployment"
        echo "📊 Monitor at: https://github.com/$REPO_INFO/actions"
    else
        echo ""
        print_header "❌ Missing Secrets"
        echo "Please add the following secrets:"
        for secret in "${MISSING_SECRETS[@]}"; do
            echo "   • $secret"
        done
        echo ""
        echo "🔗 Add secrets at: $SECRETS_URL"
    fi
    
else
    print_warning "GitHub CLI not found - manual verification required"
    echo ""
    echo "📋 Please manually verify these secrets exist in your repository:"
    echo "   • GCP_PROJECT_ID"
    echo "   • GCP_REGION"
    echo "   • GCP_REPOSITORY"
    echo "   • GCP_SA_KEY"
    echo ""
    echo "🔗 Check at: $SECRETS_URL"
    echo ""
    echo "💡 To install GitHub CLI for automatic validation:"
    echo "   brew install gh    # macOS"
    echo "   gh auth login      # authenticate"
fi

echo ""
print_header "🔄 Next Steps"
echo "1. Ensure all 4 secrets are configured in GitHub"
echo "2. Push any commit to main branch"
echo "3. Check GitHub Actions tab for deployment progress"
echo "4. Monitor deployment logs for any issues"
echo ""
echo "🆘 If deployment fails:"
echo "   • Check GitHub Actions logs"
echo "   • Verify GCP project has billing enabled"
echo "   • Ensure Cloud Run API is enabled" 