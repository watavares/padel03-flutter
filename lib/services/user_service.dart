import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Service for managing user data in Firestore
class UserService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Users collection reference
  static CollectionReference get _usersCollection => FirestoreService.collection('users');

  /// Create a new user document
  static Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
      await _analytics.logEvent(
        name: 'user_created',
        parameters: {
          'user_id': user.uid,
          'email': user.email,
        },
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Get user by ID
  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get user stream by ID
  static Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          
          // Ensure uid field is present (for backward compatibility)
          if (!data.containsKey('uid') || data['uid'] == null) {
            data['uid'] = uid;
          }
          
          // Ensure email field is present (required field)
          if (!data.containsKey('email') || data['email'] == null) {
            // If no email, we can't create a valid user model
            print('⚠️ User document missing required email field for uid: $uid');
            return null;
          }
          
          return UserModel.fromJson(data);
        } catch (e) {
          print('❌ Error parsing user document for uid $uid: $e');
          return null;
        }
      }
      return null;
    });
  }

  /// Update user document
  static Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.withUpdatedTimestamp();
      await _usersCollection.doc(user.uid).update(updatedUser.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Update specific user fields
  static Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(uid).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  /// Update user location
  static Future<void> updateUserLocation(String uid, UserLocation location) async {
    try {
      await updateUserFields(uid, {
        'location': location.toJson(),
      });

      await _analytics.logEvent(
        name: 'location_updated',
        parameters: {
          'user_id': uid,
          'source': location.source,
          'city': location.city,
          'country': location.country,
        },
      );
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
  }

  /// Update user skill assessment
  static Future<void> updateUserSkill(String uid, UserSkill skill) async {
    try {
      await updateUserFields(uid, {
        'skill': skill.toJson(),
        'onboarding.quizCompleted': skill.isComplete,
      });

      if (skill.isComplete) {
        await _analytics.logEvent(
          name: 'skill_assessment_completed',
          parameters: {
            'user_id': uid,
            'quiz_score': skill.quizScore!,
            'computed_level': skill.computedLevel!.name,
            'effective_level': skill.effectiveLevel!.name,
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  /// Update user availability
  static Future<void> updateUserAvailability(String uid, WeeklyAvailability availability) async {
    try {
      await updateUserFields(uid, {
        'availability': availability.toJson(),
        'onboarding.availabilityProvided': true,
      });

      await _analytics.logEvent(
        name: 'availability_updated',
        parameters: {
          'user_id': uid,
        },
      );
    } catch (e) {
      throw Exception('Failed to update availability: $e');
    }
  }

  /// Update onboarding progress
  static Future<void> updateOnboardingProgress(String uid, OnboardingProgress progress) async {
    try {
      await updateUserFields(uid, {
        'onboarding': progress.toJson(),
      });

      if (progress.completed) {
        await _analytics.logEvent(
          name: 'onboarding_completed',
          parameters: {
            'user_id': uid,
            'quiz_completed': progress.quizCompleted,
            'availability_provided': progress.availabilityProvided,
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to update onboarding progress: $e');
    }
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding(String uid) async {
    try {
      await updateUserFields(uid, {
        'onboarding.completed': true,
      });

      await _analytics.logEvent(
        name: 'onboarding_completed',
        parameters: {
          'user_id': uid,
        },
      );
    } catch (e) {
      throw Exception('Failed to complete onboarding: $e');
    }
  }

  /// Update user photo URL
  static Future<void> updateUserPhoto(String uid, String photoUrl) async {
    try {
      await updateUserFields(uid, {
        'photoUrl': photoUrl,
      });

      await _analytics.logEvent(
        name: 'profile_photo_updated',
        parameters: {
          'user_id': uid,
        },
      );
    } catch (e) {
      throw Exception('Failed to update photo: $e');
    }
  }

  /// Update user display name
  static Future<void> updateUserDisplayName(String uid, String displayName) async {
    try {
      await updateUserFields(uid, {
        'displayName': displayName.trim(),
      });
    } catch (e) {
      throw Exception('Failed to update display name: $e');
    }
  }

  /// Delete user document
  static Future<void> deleteUser(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();

      await _analytics.logEvent(
        name: 'user_deleted',
        parameters: {
          'user_id': uid,
        },
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Search users by location proximity (basic implementation)
  static Future<List<UserModel>> getUsersNearLocation({
    required double lat,
    required double lng,
    double radiusKm = 50.0,
    int limit = 20,
  }) async {
    try {
      // Note: This is a basic implementation. For production, consider using
      // Firestore's geohash queries or a specialized geospatial database
      final query = await _usersCollection
          .where('location', isNotEqualTo: null)
          .limit(limit)
          .get();

      final users = query.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) {
            if (user.location == null) return false;
            final distance = _calculateDistance(
              lat,
              lng,
              user.location!.lat,
              user.location!.lng,
            );
            return distance <= radiusKm;
          })
          .toList();

      return users;
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Check if user exists
  static Future<bool> userExists(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user count (for analytics)
  static Future<int> getUserCount() async {
    try {
      final query = await _usersCollection.count().get();
      return query.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

