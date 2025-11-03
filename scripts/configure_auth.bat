@echo off
echo 🔐 Configuring Firebase Authentication Providers
echo ================================================

REM Development environment
echo.
echo 📱 Configuring Development Environment (padel03-dev)
firebase use padel03-dev

echo Enabling Email/Password authentication...
REM Email/Password is enabled by default

echo Enabling Google authentication...
REM Note: This requires manual configuration in Firebase Console
echo ⚠️  Please manually enable Google Sign-In in Firebase Console:
echo    1. Go to: https://console.firebase.google.com/project/padel03-dev/authentication/providers
echo    2. Click 'Google' and enable it
echo    3. Add authorized domains: localhost, 127.0.0.1

echo.
echo 📱 Configuring Staging Environment (padel03-staging)
firebase use padel03-staging

echo ⚠️  Please manually enable Google Sign-In in Firebase Console:
echo    1. Go to: https://console.firebase.google.com/project/padel03-staging/authentication/providers
echo    2. Click 'Google' and enable it
echo    3. Add authorized domains: localhost, 127.0.0.1

echo.
echo 📱 Configuring Production Environment (padel03-prod)
firebase use padel03-prod

echo ⚠️  Please manually enable Google Sign-In in Firebase Console:
echo    1. Go to: https://console.firebase.google.com/project/padel03-prod/authentication/providers
echo    2. Click 'Google' and enable it
echo    3. Add your production domain

echo.
echo ✅ Configuration steps provided!
echo Please follow the manual steps above to complete the setup.
pause