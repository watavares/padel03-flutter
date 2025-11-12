# 🚀 Firebase Hosting Deployment Guide

## 📋 Overview

This project is configured for automatic deployment to Firebase Hosting across three environments:

- **Development** (`dev`) → `padel03-dev`
- **Staging** (`stg`) → `padel03-staging`  
- **Production** (`prod`) → `padel03-prod`

## 🛠️ Manual Deployment

### Using the Deploy Script (Recommended)

```bash
# Make script executable (first time only)
chmod +x deploy.sh

# Deploy to different environments
./deploy.sh dev   # Deploy to development
./deploy.sh stg   # Deploy to staging  
./deploy.sh prod  # Deploy to production
```

### Using Firebase CLI Directly

```bash
# Development
flutter build web --dart-define=FLAVOR=dev --output=build/web-dev
firebase use dev
firebase deploy --only hosting:hosting-dev

# Staging
flutter build web --dart-define=FLAVOR=staging --output=build/web-stg
firebase use stg
firebase deploy --only hosting:hosting-stg

# Production
flutter build web --dart-define=FLAVOR=production --release
firebase use prod
firebase deploy --only hosting:hosting-prod
```

## 🔄 Automatic Deployment

GitHub Actions automatically deploys based on branch:

| Branch | Environment | Trigger | URL |
|--------|-------------|---------|-----|
| `develop` | Development | Push | https://padel03-dev.web.app |
| `staging` | Staging | Push | https://padel03-staging.web.app |
| `main` | Production | Push | https://padel03-prod.web.app |
| Any branch | Preview | Pull Request | Temporary preview URL |

## 🔍 Preview Channels

### Create Preview Channel Manually

```bash
# Create a preview for testing
firebase hosting:channel:deploy CHANNEL_NAME --project=padel03-prod

# Example: Create a feature preview
firebase hosting:channel:deploy feature-new-ui --project=padel03-prod
```

### Preview URLs

Preview channels create temporary URLs like:
- `https://padel03-prod--feature-new-ui-abc123.web.app`

### List Active Channels

```bash
firebase hosting:channel:list --project=padel03-prod
```

### Delete Preview Channel

```bash
firebase hosting:channel:delete CHANNEL_NAME --project=padel03-prod
```

## 🌐 Custom Domain Setup

### 1. Add Custom Domain in Firebase Console

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain (e.g., `www.padelarena.com`)
4. Follow DNS verification steps

### 2. Configure DNS Records

Add these DNS records to your domain provider:

```
Type: A
Name: @
Value: 151.101.1.195
       151.101.65.195

Type: CNAME  
Name: www
Value: padelapp-prod.web.app
```

### 3. SSL Certificate

Firebase automatically provisions SSL certificates for custom domains.

## 🔐 Firebase Authentication Setup

### Add Authorized Domains

In Firebase Console → Authentication → Settings → Authorized domains:

```
# Development
padel03-dev.web.app
padel03-dev.firebaseapp.com
localhost

# Staging  
padel03-staging.web.app
padel03-staging.firebaseapp.com

# Production
padel03-prod.web.app
padel03-prod.firebaseapp.com
www.padelarena.com
padelarena.com
```

## 🔑 Required Secrets

Add these secrets to GitHub repository settings:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `FIREBASE_SERVICE_ACCOUNT_PADEL03_DEV` | Development service account | Firebase Console → Project Settings → Service Accounts |
| `FIREBASE_SERVICE_ACCOUNT_PADEL03_STG` | Staging service account | Firebase Console → Project Settings → Service Accounts |
| `FIREBASE_SERVICE_ACCOUNT_PADEL03_PROD` | Production service account | Firebase Console → Project Settings → Service Accounts |

### Generate Service Account Key

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Copy the entire JSON content
4. Add as GitHub secret (including the `{}` braces)

## 📊 Monitoring & Analytics

### Check Deployment Status

```bash
# View hosting history
firebase hosting:sites:list --project=padel03-prod

# View site details
firebase hosting:sites:get padel03-prod --project=padel03-prod
```

### Performance Monitoring

- Enable in Firebase Console → Performance
- Automatic web vitals tracking included
- View metrics in Firebase Console

## 🛡️ Security & Caching

### Cache Configuration

- **Static assets** (JS, CSS, images): 1 year cache
- **index.html**: No cache (always fresh)
- **Service worker**: No cache (critical updates)

### Security Headers

Configured in `firebase.json`:
- Content Security Policy
- X-Frame-Options  
- X-Content-Type-Options

## 🚨 Troubleshooting

### Build Fails

```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Verify Flutter version
flutter --version

# Check for errors
flutter analyze
```

### Deployment Fails

```bash
# Check Firebase authentication
firebase login --reauth

# Verify project access
firebase projects:list

# Check deployment status
firebase hosting:channel:list --project=padelapp-prod
```

### Domain Issues

```bash
# Verify DNS propagation
nslookup www.padelarena.com

# Check domain status in Firebase
firebase hosting:sites:get padelapp-prod --project=padelapp-prod
```

## 📞 Support

For deployment issues:
1. Check GitHub Actions logs
2. Verify Firebase project permissions
3. Ensure all secrets are properly configured
4. Test local deployment with `./deploy.sh`