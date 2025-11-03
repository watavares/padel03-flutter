import 'package:flutter/material.dart';
import '../services/service_manager.dart';
import '../config/app_config.dart';

class FirebaseStatusWidget extends StatelessWidget {
  const FirebaseStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Firebase Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildStatusRow('Environment', AppConfig.environment.name.toUpperCase()),
            _buildStatusRow('App Name', AppConfig.appName),
            _buildStatusRow('Bundle ID', AppConfig.bundleId),
            _buildStatusRow('API Base URL', AppConfig.apiBaseUrl),
            _buildStatusRow('Firebase', ServiceManager.isInitialized ? 'Connected' : 'Not Connected'),
            _buildStatusRow('Analytics', AppConfig.enableAnalytics ? 'Enabled' : 'Disabled'),
            _buildStatusRow('Crashlytics', AppConfig.enableCrashlytics ? 'Enabled' : 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: label == 'Firebase' 
                    ? (ServiceManager.isInitialized ? Colors.green : Colors.red)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}