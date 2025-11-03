# 📊 Visual CI/CD Pipeline Flow

## 🌊 Your Development Flow

```
📝 Local Development
│
├── 1. Create feature branch
│   git checkout -b feature/my-feature
│
├── 2. Make changes
│   ├── Edit code
│   ├── flutter test (run locally)
│   └── dart format . (format locally)
│
├── 3. Commit & Push
│   ├── git add .
│   ├── git commit -m "feat: my feature"
│   └── git push origin feature/my-feature
│
└── 4. Create Pull Request
    └── GitHub automatically triggers...
```

## 🔄 Pull Request Pipeline

```
🚀 PR Created
│
├── 📋 PR Checks Workflow Starts
│   │
│   ├── ⚡ Checkout Code
│   │   └── Downloads your branch
│   │
│   ├── 🛠️ Setup Flutter
│   │   └── Installs Flutter SDK
│   │
│   ├── 📦 Get Dependencies
│   │   └── flutter pub get
│   │
│   ├── ✨ Format Check
│   │   ├── dart format --output=none --set-exit-if-changed .
│   │   └── ✅ Pass / ❌ Fail
│   │
│   ├── 🔍 Code Analysis
│   │   ├── dart analyze --fatal-warnings
│   │   └── ✅ Pass / ❌ Fail
│   │
│   ├── 🧪 Run Tests
│   │   ├── flutter test --coverage
│   │   └── ✅ Pass / ❌ Fail
│   │
│   ├── 🏗️ Build Validation
│   │   ├── flutter build web (dev)
│   │   ├── flutter build web (staging)
│   │   └── ✅ Pass / ❌ Fail
│   │
│   └── 📝 Comment Results on PR
│       └── Shows coverage, status, etc.
│
└── 🎯 Results
    ├── ✅ All checks pass → Ready to merge
    └── ❌ Some checks fail → Fix issues first
```

## 🏭 Main CI/CD Pipeline (After Merge)

```
🔀 Code Merged to Main/Develop
│
├── 🚀 CI/CD Pipeline Triggers
│   │
│   ├── 📋 Job 1: Test & Quality
│   │   ├── Setup Flutter
│   │   ├── Get dependencies
│   │   ├── Format check
│   │   ├── Code analysis
│   │   ├── Run all tests
│   │   └── Upload coverage report
│   │
│   ├── 🌐 Job 2: Build Web (Parallel)
│   │   ├── Build for dev environment
│   │   ├── Build for staging environment
│   │   ├── Build for prod environment
│   │   └── Archive web builds
│   │
│   ├── 📱 Job 3: Build Android (Parallel)
│   │   ├── Setup Java & Android SDK
│   │   ├── Build APK (release)
│   │   ├── Build App Bundle
│   │   └── Archive Android builds
│   │
│   ├── 🍎 Job 4: Build iOS (Parallel)
│   │   ├── Run on macOS runner
│   │   ├── Build iOS app (no codesign)
│   │   └── Archive iOS build
│   │
│   └── 🚀 Job 5: Deploy Web
│       ├── Download web builds
│       ├── Setup Firebase CLI
│       ├── Deploy to dev environment
│       ├── Deploy to staging environment
│       └── Deploy to prod environment
│
└── 🎯 Results
    ├── ✅ Success → Your app is live!
    └── ❌ Failure → Check logs and fix
```

## 📦 Release Pipeline

```
🏷️ Version Tag Created (v1.0.0)
│
├── 🚀 Release Workflow Triggers
│   │
│   ├── 📋 Pre-Release Checks
│   │   ├── Checkout code
│   │   ├── Setup Flutter
│   │   ├── Get dependencies
│   │   └── Run tests
│   │
│   ├── 🏗️ Release Builds
│   │   ├── Update version in pubspec.yaml
│   │   ├── Build web (production)
│   │   ├── Archive release artifacts
│   │   └── Generate release notes
│   │
│   ├── 📋 Create GitHub Release
│   │   ├── Create release page
│   │   ├── Upload artifacts
│   │   ├── Add release notes
│   │   └── Mark as latest release
│   │
│   └── 🚀 Deploy Release
│       ├── Deploy to Firebase Hosting
│       ├── Update production environment
│       └── Send deployment notifications
│
└── 🎯 Results
    ├── ✅ Success → New version is live!
    └── ❌ Failure → Check logs and re-tag
```

## 🎮 Interactive Commands You Can Use

### 🔧 Local Development Commands
```bash
# Check your code before pushing
flutter test                    # Run tests
dart format .                   # Format code
dart analyze                    # Check for issues
flutter build web               # Test build locally

# Git workflow
git status                      # See what changed
git add .                       # Stage changes
git commit -m "description"     # Commit changes
git push origin branch-name     # Push to GitHub
```

### 🏷️ Release Commands
```bash
# Create a new release
git tag v1.0.0                  # Create version tag
git push origin v1.0.0          # Push tag (triggers release)

# List existing tags
git tag -l                      # Show all tags

# Delete a tag (if needed)
git tag -d v1.0.0               # Delete local tag
git push origin :refs/tags/v1.0.0  # Delete remote tag
```

### 🔍 Monitoring Commands
```bash
# Check current branch and status
git branch -a                   # Show all branches
git log --oneline -5            # Show recent commits
git remote -v                   # Show remote repositories

# Firebase commands
firebase projects:list          # Show your Firebase projects
firebase use project-name       # Switch to a project
firebase deploy --only hosting  # Manual deploy
```

## 🎯 What Each Status Means

### ✅ Success States
```
✅ Checks Passed    → All tests and builds succeeded
✅ Deployed         → Your app is live and accessible
✅ Coverage Good    → Your tests cover enough code
✅ Build Artifacts  → Downloadable app files created
```

### ⏳ In Progress States
```
🟡 Running         → Pipeline is currently executing
🟡 Pending         → Waiting for previous jobs to complete
🟡 Queued          → Waiting for available runner
```

### ❌ Failure States
```
❌ Test Failed     → One or more tests didn't pass
❌ Build Failed    → Code couldn't compile
❌ Format Issues   → Code formatting needs fixing
❌ Deploy Failed   → Couldn't publish to Firebase
```

## 🚨 Emergency Procedures

### If Main Branch is Broken
```bash
# Create hotfix branch
git checkout main
git pull origin main
git checkout -b hotfix/urgent-fix

# Make fix
# ... fix the issue ...

# Test locally
flutter test
flutter build web

# Push and create urgent PR
git add .
git commit -m "hotfix: fix critical issue"
git push origin hotfix/urgent-fix
# Create PR immediately
```

### If Pipeline is Stuck
1. Go to Actions tab: https://github.com/watavares/padel03-flutter/actions
2. Find the stuck workflow
3. Click "Cancel workflow"
4. Re-run by pushing a new commit

### If Deployment Fails
1. Check Firebase console: https://console.firebase.google.com
2. Verify project permissions
3. Check if FIREBASE_TOKEN secret is valid
4. Re-run deployment manually if needed

---

## 🎓 Learning Path

### Week 1: Basic Understanding
- [ ] Read this guide completely
- [ ] Create your first Pull Request
- [ ] Watch the pipeline run
- [ ] Understand success/failure indicators

### Week 2: Hands-on Practice
- [ ] Make code changes and fix formatting issues
- [ ] Deliberately break a test and fix it
- [ ] Create a release tag
- [ ] Read pipeline logs

### Week 3: Advanced Usage
- [ ] Understand branch protection rules
- [ ] Explore different build environments
- [ ] Learn about secrets management
- [ ] Optimize pipeline performance

Remember: **The best way to learn is by doing!** Start with small changes and gradually work your way up. 🚀