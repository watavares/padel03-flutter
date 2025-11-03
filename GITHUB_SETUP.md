# GitHub Repository Setup Instructions

## 🚀 Create GitHub Repository

### Step 1: Create Repository on GitHub
1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" button in the top right corner
3. Select "New repository"
4. Fill in the details:
   - **Repository name**: `padel03-flutter`
   - **Description**: `Flutter Padel application with multi-environment Firebase integration`
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README (we already have one)
   - **DO NOT** add .gitignore (we already have one)
   - **DO NOT** add license (you can add one later)

### Step 2: Connect Local Repository to GitHub
```bash
# Add remote origin (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/padel03-flutter.git

# Verify remote was added
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Set Up Repository Settings
1. Go to your repository on GitHub
2. Click on "Settings" tab
3. Configure the following:

#### Branch Protection Rules
1. Go to "Branches" in settings
2. Add rule for `main` branch:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators

#### Secrets and Variables
1. Go to "Secrets and variables" → "Actions"
2. Add the following secrets:

**Repository Secrets:**
```
FIREBASE_TOKEN
```

To get Firebase token:
```bash
firebase login:ci
```

#### Repository Topics
Add these topics to help with discoverability:
- `flutter`
- `firebase`
- `padel`
- `mobile-app`
- `web-app`
- `multi-platform`
- `authentication`
- `firestore`

### Step 4: Enable GitHub Features
1. **Issues**: Enable in repository settings
2. **Discussions**: Enable if you want community discussions
3. **Projects**: Enable for project management
4. **Wiki**: Enable for documentation

### Step 5: Set Up GitHub Pages (Optional)
1. Go to "Settings" → "Pages"
2. Source: "Deploy from a branch"
3. Branch: `main`
4. Folder: `/docs` (if you add documentation)

## 🔧 Environment Configuration

### Firebase Configuration
1. **Development Environment**:
   - Project: `padel03-dev`
   - Hosting URL: `https://padel03-dev.web.app`

2. **Staging Environment**:
   - Project: `padel03-staging`
   - Hosting URL: `https://padel03-staging.web.app`

3. **Production Environment**:
   - Project: `padel03-prod`
   - Hosting URL: `https://padel03-prod.web.app`

### GitHub Actions Secrets Setup
Add these secrets in GitHub repository settings:

1. **FIREBASE_TOKEN**: 
   ```bash
   firebase login:ci
   # Copy the token and add it as a secret
   ```

2. **Optional Secrets** (for future use):
   - `FIREBASE_SERVICE_ACCOUNT_KEY_DEV`
   - `FIREBASE_SERVICE_ACCOUNT_KEY_STAGING`
   - `FIREBASE_SERVICE_ACCOUNT_KEY_PROD`
   - `CODECOV_TOKEN` (for coverage reporting)

## 🎯 Post-Setup Actions

### 1. Update README.md
Replace `[YOUR-USERNAME]` in README.md with your actual GitHub username:
```bash
# In the repository clone URL section
git clone https://github.com/YOUR_ACTUAL_USERNAME/padel03-flutter.git
```

### 2. Update Dependabot Configuration
In `.github/dependabot.yml`, replace:
```yaml
assignees:
  - "your-github-username"
reviewers:
  - "your-github-username"
```
With your actual GitHub username.

### 3. Test the Pipeline
1. Create a new branch:
   ```bash
   git checkout -b test/ci-pipeline
   ```

2. Make a small change (e.g., update README)

3. Push and create a PR:
   ```bash
   git add .
   git commit -m "Test CI pipeline"
   git push origin test/ci-pipeline
   ```

4. Go to GitHub and create a Pull Request

5. Verify that the CI checks run automatically

### 4. First Release
After everything is working:
```bash
git tag v1.0.0
git push origin v1.0.0
```

This will trigger the release workflow.

## 📋 Checklist
- [ ] Created GitHub repository
- [ ] Connected local repo to GitHub
- [ ] Pushed initial code
- [ ] Set up branch protection rules
- [ ] Added Firebase token secret
- [ ] Updated README with correct URLs
- [ ] Updated dependabot configuration
- [ ] Tested CI pipeline with a PR
- [ ] Created first release tag

## 🆘 Troubleshooting

### Common Issues:
1. **Firebase token issues**: Make sure the token has the right permissions
2. **Branch protection**: Ensure the required status checks match your workflow names
3. **Secrets**: Check that secret names match exactly in workflows

### Getting Help:
- Check GitHub Actions logs for detailed error messages
- Verify Firebase project permissions
- Ensure all required secrets are properly set

---

**Next Steps**: Follow these instructions to complete the GitHub setup, then we can test the full CI/CD pipeline!