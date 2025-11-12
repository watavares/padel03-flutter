import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_staging.dart';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    return DefaultFirebaseOptions.currentPlatform;
  }
}
