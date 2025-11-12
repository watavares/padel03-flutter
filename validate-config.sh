#!/bin/bash

# 🔍 Firebase Configuration Validator
# This script validates your Firebase Hosting setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info "🔍 Validating Firebase Hosting Configuration..."
echo ""

# Check if required files exist
FILES=(".firebaserc" "firebase.json" "deploy.sh" ".github/workflows/deploy-web.yml")
ALL_FILES_EXIST=true

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Found: $file"
    else
        print_error "Missing: $file"
        ALL_FILES_EXIST=false
    fi
done

echo ""

# Check Flutter installation
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
    print_success "Flutter installed: $FLUTTER_VERSION"
else
    print_error "Flutter is not installed or not in PATH"
fi

# Check Firebase CLI installation
if command -v firebase &> /dev/null; then
    FIREBASE_VERSION=$(firebase --version)
    print_success "Firebase CLI installed: $FIREBASE_VERSION"
else
    print_error "Firebase CLI is not installed"
    print_info "Install with: npm install -g firebase-tools"
fi

echo ""

# Validate .firebaserc
if [ -f ".firebaserc" ]; then
    print_info "Validating .firebaserc..."
    
    if grep -q "padel03-dev" .firebaserc && \
       grep -q "padel03-staging" .firebaserc && \
       grep -q "padel03-prod" .firebaserc; then
        print_success ".firebaserc contains all required projects"
    else
        print_warning ".firebaserc may be missing some project configurations"
    fi
fi

# Validate firebase.json
if [ -f "firebase.json" ]; then
    print_info "Validating firebase.json..."
    
    if grep -q "hosting-dev" firebase.json && \
       grep -q "hosting-stg" firebase.json && \
       grep -q "hosting-prod" firebase.json; then
        print_success "firebase.json contains all hosting targets"
    else
        print_warning "firebase.json may be missing some hosting targets"
    fi
    
    if grep -q "Cache-Control" firebase.json; then
        print_success "firebase.json includes cache headers"
    else
        print_warning "firebase.json may be missing cache configuration"
    fi
fi

echo ""

# Check GitHub Actions workflow
if [ -f ".github/workflows/deploy-web.yml" ]; then
    print_info "Validating GitHub Actions workflow..."
    
    if grep -q "FIREBASE_SERVICE_ACCOUNT" .github/workflows/deploy-web.yml; then
        print_success "GitHub Actions workflow includes Firebase service account secrets"
    else
        print_warning "GitHub Actions workflow may be missing Firebase secrets"
    fi
else
    print_warning "GitHub Actions workflow not found"
fi

echo ""

# Check if we're in a git repository
if [ -d ".git" ]; then
    print_success "Git repository detected"
    
    # Check current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    print_info "Current branch: $CURRENT_BRANCH"
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        print_warning "You have uncommitted changes"
    else
        print_success "Working directory is clean"
    fi
else
    print_warning "Not in a git repository"
fi

echo ""

# Final summary
if [ "$ALL_FILES_EXIST" = true ]; then
    print_success "🎉 All required files are present!"
    echo ""
    print_info "Next steps:"
    echo "  1. Ensure Firebase projects exist (padel03-dev, padel03-staging, padel03-prod)"
    echo "  2. Add GitHub secrets for Firebase service accounts"
    echo "  3. Test deployment: ./deploy.sh dev"
    echo "  4. Push to GitHub to trigger automatic deployment"
else
    print_error "❌ Some required files are missing!"
    echo ""
    print_info "Please ensure all configuration files are in place before deploying."
fi

echo ""
print_info "📖 For detailed instructions, see: FIREBASE_DEPLOYMENT_README.md"