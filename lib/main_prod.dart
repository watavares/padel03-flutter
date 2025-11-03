import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'services/service_manager.dart';
import 'main.dart' as main_app;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set production environment
  AppConfig.setEnvironment(Environment.prod);

  // Initialize services
  await ServiceManager.initialize();

  // Run the app
  main_app.runMainApp();
}
