#!/bin/bash

# 🚀 PadelArena Firebase Hosting Deployment Script
# Usage: ./deploy.sh [dev|stg|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
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

# Check if environment is provided
if [ $# -eq 0 ]; then
    print_error "Environment not specified!"
    echo ""
    echo "Usage: $0 [dev|stg|prod]"
    echo ""
    echo "Examples:"
    echo "  $0 dev   → Deploy to padelapp-dev"
    echo "  $0 stg   → Deploy to padelapp-stg"
    echo "  $0 prod  → Deploy to padelapp-prod"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
case $ENVIRONMENT in
    dev)
        PROJECT_ID="padel03-dev"
        TARGET="hosting-dev"
        BUILD_DIR="build/web-dev"
        FLAVOR="dev"
        ;;
    stg)
        PROJECT_ID="padel03-staging"
        TARGET="hosting-stg"
        BUILD_DIR="build/web-stg"
        FLAVOR="staging"
        ;;
    prod)
        PROJECT_ID="padel03-prod"
        TARGET="hosting-prod"
        BUILD_DIR="build/web"
        FLAVOR="production"
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        echo "Valid environments: dev, stg, prod"
        exit 1
        ;;
esac

print_info "🎯 Deploying PadelArena to $ENVIRONMENT environment"
print_info "📂 Project ID: $PROJECT_ID"
print_info "🎪 Target: $TARGET"
print_info "📁 Build directory: $BUILD_DIR"
print_info "🏷️  Flavor: $FLAVOR"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI is not installed"
    print_info "Install it with: npm install -g firebase-tools"
    exit 1
fi

# Clean previous builds
print_info "🧹 Cleaning previous builds..."
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi

# Get Flutter dependencies
print_info "📦 Getting Flutter dependencies..."
flutter pub get

# Build Flutter web app
print_info "🔨 Building Flutter web app for $ENVIRONMENT..."
case $ENVIRONMENT in
    dev)
        flutter build web --dart-define=FLAVOR=dev --output="$BUILD_DIR"
        ;;
    stg)
        flutter build web --dart-define=FLAVOR=staging --output="$BUILD_DIR"
        ;;
    prod)
        flutter build web --dart-define=FLAVOR=production --output="$BUILD_DIR" --release
        ;;
esac

if [ $? -ne 0 ]; then
    print_error "Flutter build failed!"
    exit 1
fi

print_success "Flutter build completed successfully!"

# Verify build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    print_error "Build directory $BUILD_DIR does not exist!"
    exit 1
fi

# Deploy to Firebase
print_info "🚀 Deploying to Firebase Hosting..."
firebase use "$ENVIRONMENT"
firebase deploy --only hosting:"$TARGET"

if [ $? -eq 0 ]; then
    print_success "🎉 Deployment to $ENVIRONMENT completed successfully!"
    
    # Show deployment URL
    case $ENVIRONMENT in
        dev)
            echo ""
            print_info "🌐 Your app is live at:"
            echo "   https://padel03-dev.web.app"
            echo "   https://padel03-dev.firebaseapp.com"
            ;;
        stg)
            echo ""
            print_info "🌐 Your app is live at:"
            echo "   https://padel03-staging.web.app"
            echo "   https://padel03-staging.firebaseapp.com"
            ;;
        prod)
            echo ""
            print_info "🌐 Your app is live at:"
            echo "   https://padel03-prod.web.app"
            echo "   https://padel03-prod.firebaseapp.com"
            echo "   https://www.padelarena.com (if custom domain is configured)"
            ;;
    esac
else
    print_error "Deployment failed!"
    exit 1
fi