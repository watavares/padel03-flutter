import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase/firebase_service.dart';
import 'routing/app_router.dart';
import 'design_system/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using our Firebase service
  try {
    await FirebaseService.initializeFirebase();
    print('✅ Firebase initialized successfully via FirebaseService');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Continue without Firebase for now
  }

  runMainApp();
}

/// Exported function for environment-specific entry points
void runMainApp() {
  runApp(
    const ProviderScope(
      child: PadelConnectApp(),
    ),
  );
}

class PadelConnectApp extends ConsumerWidget {
  const PadelConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'PadelConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
