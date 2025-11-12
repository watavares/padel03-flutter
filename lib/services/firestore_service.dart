import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_service.dart';
import '../config/app_config.dart';

class FirestoreService {
  static FirebaseFirestore get _firestore => FirebaseService.firestore;

  // Collection references with environment prefix
  static String _getCollectionName(String collection) {
    final env = AppConfig.environment.name;
    return '${env}_$collection'; // e.g., "dev_users", "prod_users"
  }

  // Generic CRUD operations
  static CollectionReference<Map<String, dynamic>> collection(String name) {
    return _firestore.collection(_getCollectionName(name));
  }

  // Create document
  static Future<DocumentReference> create(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      return await FirestoreService.collection(collection).add(docData);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  // Create document with custom ID
  static Future<void> createWithId(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final docData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirestoreService.collection(
        collection,
      ).doc(documentId).set(docData);
    } catch (e) {
      throw Exception('Failed to create document with ID: $e');
    }
  }

  // Read document
  static Future<DocumentSnapshot<Map<String, dynamic>>> read(
    String collection,
    String documentId,
  ) async {
    try {
      return await FirestoreService.collection(
        collection,
      ).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to read document: $e');
    }
  }

  // Update document
  static Future<void> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updateData = {...data, 'updatedAt': FieldValue.serverTimestamp()};
      await FirestoreService.collection(
        collection,
      ).doc(documentId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  // Delete document
  static Future<void> delete(String collection, String documentId) async {
    try {
      await FirestoreService.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Stream document
  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collection,
    String documentId,
  ) {
    return FirestoreService.collection(collection).doc(documentId).snapshots();
  }

  // Stream collection
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query<Map<String, dynamic>>? Function(
      CollectionReference<Map<String, dynamic>>,
    )?
    queryBuilder,
  }) {
    CollectionReference<Map<String, dynamic>> ref = FirestoreService.collection(
      collection,
    );

    if (queryBuilder != null) {
      final query = queryBuilder(ref);
      if (query != null) {
        return query.snapshots();
      }
    }

    return ref.snapshots();
  }

  // Batch operations
  static WriteBatch batch() => _firestore.batch();

  static Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to commit batch: $e');
    }
  }

  // Transaction
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction<T>(updateFunction);
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  // User-specific operations
  static Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? additionalData,
  }) async {
    final userData = {
      'uid': userId,  // Add the missing uid field
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isActive': true,
      'lastLoginAt': FieldValue.serverTimestamp(),
      ...?additionalData,
    };

    await createWithId('users', userId, userData);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String userId,
  ) {
    return read('users', userId);
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(
    String userId,
  ) {
    return streamDocument('users', userId);
  }

  static Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) {
    return update('users', userId, data);
  }

  // Padel-specific collections
  static CollectionReference<Map<String, dynamic>> get courts {
    return collection('courts');
  }

  static CollectionReference<Map<String, dynamic>> get bookings {
    return collection('bookings');
  }

  static CollectionReference<Map<String, dynamic>> get matches {
    return collection('matches');
  }

  static CollectionReference<Map<String, dynamic>> get tournaments {
    return collection('tournaments');
  }

  static CollectionReference<Map<String, dynamic>> get players {
    return collection('players');
  }

  // Environment info
  static String get currentEnvironment => AppConfig.environment.name;
  static String get environmentPrefix => '${AppConfig.environment.name}_';
}
