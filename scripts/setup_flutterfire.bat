@echo off
REM Add Pub cache to PATH for this session
set PATH=%PATH%;C:\Users\Laptop\AppData\Local\Pub\Cache\bin

REM Now you can use flutterfire command directly
echo FlutterFire CLI is now available. You can use: flutterfire --help
echo.
echo Available commands:
echo   flutterfire configure --project=padel03-dev
echo   flutterfire configure --project=padel03-staging  
echo   flutterfire configure --project=padel03-prod
echo.
cmd /k