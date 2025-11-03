# 🎯 Hands-On CI/CD Exercise

## 🎮 **Exercise 1: Your First Pull Request**

Let's create a Pull Request to see your pipeline in action!

### **Step 1: Check Your Current Status**
```bash
# You should be on test/ci-pipeline branch
git branch
# Should show: * test/ci-pipeline

# If not, switch to it:
git checkout test/ci-pipeline
```

### **Step 2: Make a Simple Change**
Let's update the app description in `pubspec.yaml`:

1. Open `pubspec.yaml`
2. Find the line: `description: A new Flutter project.`
3. Change it to: `description: Flutter Padel app with Firebase authentication and multi-environment support.`

### **Step 3: Test Locally First**
```bash
# Check if your change breaks anything
flutter pub get
flutter test

# Format your code
dart format .

# Check for issues
dart analyze
```

### **Step 4: Commit Your Change**
```bash
git add pubspec.yaml
git commit -m "docs: update app description in pubspec.yaml"
git push origin test/ci-pipeline
```

### **Step 5: Create Pull Request**
1. Go to: https://github.com/watavares/padel03-flutter
2. You'll see a banner: "Compare & pull request" - click it
3. Fill out the PR template:
   ```
   ## Description
   Update app description to better reflect the project's purpose
   
   ## Type of Change
   - [x] Documentation update
   
   ## Changes Made
   - Updated pubspec.yaml description
   
   ## Testing
   - [x] Manual testing completed
   ```

4. Click "Create pull request"

### **Step 6: Watch the Magic! ✨**
Your pipeline will automatically:
1. Check code formatting
2. Run static analysis
3. Execute all tests
4. Build the app
5. Post results as a comment

**What you'll see:**
- Yellow dots (🟡) = Running
- Green checkmarks (✅) = Success
- Red X's (❌) = Failed

---

## 🧪 **Exercise 2: Fixing a Pipeline Failure**

Let's intentionally break something and then fix it!

### **Step 1: Break the Code Format**
1. Open `lib/main.dart`
2. Add some extra spaces or remove semicolons
3. Save the file

### **Step 2: Commit the Bad Code**
```bash
git add .
git commit -m "test: intentionally break formatting"
git push origin test/ci-pipeline
```

### **Step 3: Watch it Fail**
- Go to your PR and watch the format check fail
- Click "Details" on the failed check
- Read the error message

### **Step 4: Fix the Issue**
```bash
# Fix formatting automatically
dart format .

# Commit the fix
git add .
git commit -m "fix: correct code formatting"
git push origin test/ci-pipeline
```

### **Step 5: Watch it Succeed**
The pipeline will run again and should pass!

---

## 🏷️ **Exercise 3: Create Your First Release**

After your PR is merged, let's create a release:

### **Step 1: Merge Your PR**
1. Once your PR shows all green checkmarks
2. Click "Merge pull request"
3. Click "Confirm merge"
4. Delete the test branch when prompted

### **Step 2: Switch to Main Branch**
```bash
git checkout main
git pull origin main
```

### **Step 3: Create a Release Tag**
```bash
# Create your first version tag
git tag v1.0.0
git push origin v1.0.0
```

### **Step 4: Watch the Release Pipeline**
1. Go to: https://github.com/watavares/padel03-flutter/actions
2. You'll see "Release" workflow running
3. When it completes, check: https://github.com/watavares/padel03-flutter/releases

---

## 🔍 **Exercise 4: Reading Pipeline Logs**

Let's learn to debug by reading logs:

### **Step 1: Find a Pipeline Run**
1. Go to: https://github.com/watavares/padel03-flutter/actions
2. Click on any workflow run
3. Click on a job (like "Test & Code Quality")

### **Step 2: Explore the Logs**
You'll see sections like:
```
🔽 Setup Flutter
🔽 Get dependencies  
🔽 Verify formatting
🔽 Analyze project source
🔽 Run tests
```

### **Step 3: Understanding Log Output**
**Success looks like:**
```
✅ Run flutter test
  00:01 +5: All tests passed!
```

**Failure looks like:**
```
❌ Run dart analyze
  error • lib/main.dart:10:1 • Unused import
```

---

## 🛠️ **Exercise 5: Local Development Workflow**

Practice the daily development cycle:

### **Step 1: Create a Feature Branch**
```bash
git checkout main
git pull origin main
git checkout -b feature/update-readme
```

### **Step 2: Make Changes**
Update the README.md:
- Add your name as a contributor
- Update the description
- Add any notes about your setup experience

### **Step 3: Test Everything Locally**
```bash
# Always test before pushing!
flutter test
dart format .
dart analyze
flutter build web --target=lib/main_dev.dart
```

### **Step 4: Commit and Push**
```bash
git add .
git commit -m "docs: update README with contributor info"
git push origin feature/update-readme
```

### **Step 5: Create PR and Merge**
Follow the same process as Exercise 1

---

## 📊 **Exercise 6: Understanding Different Environments**

Test your multi-environment setup:

### **Step 1: Run Different Environments Locally**
```bash
# Development environment
flutter run -t lib/main_dev.dart -d chrome

# Staging environment  
flutter run -t lib/main_staging.dart -d chrome

# Production environment
flutter run -t lib/main_prod.dart -d chrome
```

### **Step 2: Check Firebase Console**
1. Go to: https://console.firebase.google.com
2. Switch between your projects:
   - padel03-dev
   - padel03-staging  
   - padel03-prod
3. Notice how each has separate data

### **Step 3: Understand Build Differences**
```bash
# See how builds differ
flutter build web --target=lib/main_dev.dart --dart-define=ENVIRONMENT=dev
flutter build web --target=lib/main_prod.dart --dart-define=ENVIRONMENT=prod
```

---

## 🏆 **Completion Checklist**

Mark off each exercise as you complete it:

- [ ] **Exercise 1**: Created first Pull Request
- [ ] **Exercise 2**: Fixed a pipeline failure
- [ ] **Exercise 3**: Created first release
- [ ] **Exercise 4**: Read and understood pipeline logs
- [ ] **Exercise 5**: Completed full development workflow
- [ ] **Exercise 6**: Tested different environments

## 🎉 **Congratulations!**

Once you complete these exercises, you'll understand:
- ✅ How to create Pull Requests
- ✅ How to read pipeline results
- ✅ How to fix common issues
- ✅ How to create releases
- ✅ How to work with multiple environments
- ✅ How to follow proper Git workflow

## 🤝 **Getting Help**

If you get stuck:
1. **Read the error messages** carefully
2. **Check the logs** in GitHub Actions
3. **Ask specific questions** about what you don't understand
4. **Share the error output** when asking for help

Remember: Making mistakes is part of learning! Every developer breaks the pipeline sometimes. 😄

---

## 🔧 **Common Commands Reference**

```bash
# Daily Git workflow
git status                      # See what changed
git add .                       # Stage all changes
git commit -m "description"     # Commit with message
git push origin branch-name     # Push to GitHub

# Flutter testing
flutter test                    # Run tests
dart format .                   # Format code
dart analyze                   # Check for issues
flutter clean                  # Clean build cache

# Branch management
git branch                     # List branches
git checkout main              # Switch to main
git checkout -b feature/name   # Create new branch
git pull origin main           # Update from remote

# Release management
git tag v1.0.0                # Create version tag
git push origin v1.0.0        # Push tag
git tag -l                     # List all tags
```

**Now go ahead and try Exercise 1!** 🚀