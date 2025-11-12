import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/lobby_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Service for managing lobby data in Firestore
class LobbyService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Lobbies collection reference
  static CollectionReference get _lobbiesCollection => 
      FirestoreService.collection('lobbies');

  /// Create a new lobby
  static Future<String> createLobby(CreateLobbyRequest request, UserModel organizer) async {
    try {
      // Create lobby model
      final lobby = LobbyModel.create(
        title: request.title,
        organizerId: organizer.uid,
        organizerName: organizer.displayNameOrEmail,
        dateTime: request.dateTime,
        clubName: request.clubName,
        courtName: request.courtName,
        skillLevel: request.skillLevel,
        matchType: request.matchType,
        maxPlayers: request.maxPlayers,
        pricePerPlayer: request.pricePerPlayer,
        notes: request.notes,
        genderPreference: request.genderPreference,
        tags: request.tags,
      );

      // Save to Firestore - convert LobbyModel to Map manually to handle nested objects
      final lobbyData = {
        'id': '', // Will be updated later
        'title': lobby.title,
        'organizerId': lobby.organizerId,
        'organizerName': lobby.organizerName,
        'dateTime': lobby.dateTime.toIso8601String(),
        'clubName': lobby.clubName,
        'courtName': lobby.courtName,
        'skillLevel': lobby.skillLevel.name,
        'matchType': lobby.matchType.name,
        'maxPlayers': lobby.maxPlayers,
        'pricePerPlayer': lobby.pricePerPlayer,
        'notes': lobby.notes,
        'genderPreference': lobby.genderPreference,
        'tags': lobby.tags,
        'players': lobby.players.map((player) => {
          'userId': player.userId,
          'displayName': player.displayName,
          'photoUrl': player.photoUrl,
          'skillLevel': player.skillLevel?.name,
          'joinedAt': player.joinedAt?.toIso8601String(),
        }).toList(),
        'status': lobby.status.name,
        'createdAt': lobby.createdAt?.toIso8601String(),
        'updatedAt': lobby.updatedAt?.toIso8601String(),
      };
      
      final docRef = await _lobbiesCollection.add(lobbyData);
      
      // Update the document with its ID
      await docRef.update({'id': docRef.id});

      // Log analytics
      await _analytics.logEvent(
        name: 'lobby_created',
        parameters: {
          'lobby_id': docRef.id,
          'organizer_id': organizer.uid,
          'skill_level': request.skillLevel.name,
          'match_type': request.matchType.name,
          'max_players': request.maxPlayers,
          'price': request.pricePerPlayer,
          'club_name': request.clubName,
        },
      );

      print('✅ Lobby created successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating lobby: $e');
      throw Exception('Failed to create lobby: $e');
    }
  }

  /// Get lobby by ID
  static Future<LobbyModel?> getLobby(String lobbyId) async {
    try {
      final doc = await _lobbiesCollection.doc(lobbyId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return LobbyModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('❌ Error getting lobby: $e');
      throw Exception('Failed to get lobby: $e');
    }
  }

  /// Get lobbies with filters
  static Future<List<LobbyModel>> getLobbies({
    LobbyFilters? filters,
  }) async {
    try {
      Query query = _lobbiesCollection;

      // Apply filters
      if (filters != null) {
        // Filter by status
        if (filters.status != null) {
          query = query.where('status', isEqualTo: filters.status!.name);
        }

        // Filter by skill level
        if (filters.skillLevel != null) {
          query = query.where('skillLevel', isEqualTo: filters.skillLevel!.name);
        }

        // Filter by match type
        if (filters.matchType != null) {
          query = query.where('matchType', isEqualTo: filters.matchType!.name);
        }

        // Filter by gender preference
        if (filters.genderPreference != null) {
          query = query.where('genderPreference', isEqualTo: filters.genderPreference);
        }

        // Filter by club name
        if (filters.clubName != null) {
          query = query.where('clubName', isEqualTo: filters.clubName);
        }

        // Filter by date range
        if (filters.startDate != null) {
          query = query.where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(filters.startDate!));
        }
        if (filters.endDate != null) {
          query = query.where('dateTime', isLessThanOrEqualTo: Timestamp.fromDate(filters.endDate!));
        }
      }

      // Order by date and limit
      query = query.orderBy('dateTime', descending: false);
      if (filters?.limit != null) {
        query = query.limit(filters!.limit);
      }

      final snapshot = await query.get();
      
      final lobbies = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return LobbyModel.fromJson(data);
            } catch (e) {
              print('⚠️ Error parsing lobby ${doc.id}: $e');
              return null;
            }
          })
          .where((lobby) => lobby != null)
          .cast<LobbyModel>()
          .toList();

      // Apply text search filter (not supported by Firestore, so we do it client-side)
      if (filters?.searchQuery != null && filters!.searchQuery!.isNotEmpty) {
        final searchQuery = filters.searchQuery!.toLowerCase();
        return lobbies.where((lobby) {
          return lobby.title.toLowerCase().contains(searchQuery) ||
                 lobby.clubName.toLowerCase().contains(searchQuery) ||
                 lobby.notes?.toLowerCase().contains(searchQuery) == true;
        }).toList();
      }

      return lobbies;
    } catch (e) {
      print('❌ Error getting lobbies: $e');
      throw Exception('Failed to get lobbies: $e');
    }
  }

  /// Stream lobbies with real-time updates
  static Stream<List<LobbyModel>> streamLobbies({
    LobbyFilters? filters,
  }) {
    try {
      Query query = _lobbiesCollection;

      // Apply basic filters (complex filters done client-side)
      if (filters?.status != null) {
        query = query.where('status', isEqualTo: filters!.status!.name);
      }

      // Order by date
      query = query.orderBy('dateTime', descending: false);
      
      if (filters?.limit != null) {
        query = query.limit(filters!.limit);
      }

      return query.snapshots().map((snapshot) {
        var lobbies = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return LobbyModel.fromJson(data);
              } catch (e) {
                print('⚠️ Error parsing lobby ${doc.id}: $e');
                return null;
              }
            })
            .where((lobby) => lobby != null)
            .cast<LobbyModel>()
            .toList();

        // Apply client-side filters
        if (filters != null) {
          lobbies = _applyClientSideFilters(lobbies, filters);
        }

        return lobbies;
      });
    } catch (e) {
      print('❌ Error streaming lobbies: $e');
      return Stream.error('Failed to stream lobbies: $e');
    }
  }

  /// Get lobbies for a specific user
  static Stream<List<LobbyModel>> streamUserLobbies(String userId) {
    try {
      return _lobbiesCollection
          .where('players', arrayContainsAny: [
            {'userId': userId}
          ])
          .orderBy('dateTime', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    final lobby = LobbyModel.fromJson(data);
                    
                    // Double-check if user is actually in the lobby
                    if (lobby.isUserInLobby(userId)) {
                      return lobby;
                    }
                    return null;
                  } catch (e) {
                    print('⚠️ Error parsing user lobby ${doc.id}: $e');
                    return null;
                  }
                })
                .where((lobby) => lobby != null)
                .cast<LobbyModel>()
                .toList();
          });
    } catch (e) {
      print('❌ Error streaming user lobbies: $e');
      return Stream.error('Failed to stream user lobbies: $e');
    }
  }

  /// Join a lobby
  static Future<void> joinLobby(String lobbyId, UserModel user) async {
    try {
      final lobbyDoc = await _lobbiesCollection.doc(lobbyId).get();
      
      if (!lobbyDoc.exists) {
        throw Exception('Lobby not found');
      }

      final lobby = LobbyModel.fromJson(lobbyDoc.data() as Map<String, dynamic>);

      // Validation checks
      if (!lobby.isJoinable) {
        throw Exception('Lobby is not joinable');
      }

      if (lobby.isUserInLobby(user.uid)) {
        throw Exception('User is already in this lobby');
      }

      // Create player object
      final player = LobbyPlayer(
        userId: user.uid,
        displayName: user.displayNameOrEmail,
        photoUrl: user.photoUrl,
        skillLevel: user.skill.effectiveLevel,
        joinedAt: DateTime.now(),
      );

      // Update lobby with new player
      final updatedLobby = lobby.addPlayer(player);

      // Save to Firestore - manually serialize to avoid custom object issues
      final lobbyData = {
        'id': updatedLobby.id,
        'title': updatedLobby.title,
        'organizerId': updatedLobby.organizerId,
        'organizerName': updatedLobby.organizerName,
        'dateTime': updatedLobby.dateTime.toIso8601String(),
        'clubName': updatedLobby.clubName,
        'courtName': updatedLobby.courtName,
        'skillLevel': updatedLobby.skillLevel.name,
        'matchType': updatedLobby.matchType.name,
        'maxPlayers': updatedLobby.maxPlayers,
        'pricePerPlayer': updatedLobby.pricePerPlayer,
        'notes': updatedLobby.notes,
        'genderPreference': updatedLobby.genderPreference,
        'tags': updatedLobby.tags,
        'players': updatedLobby.players.map((p) => {
          'userId': p.userId,
          'displayName': p.displayName,
          'photoUrl': p.photoUrl,
          'skillLevel': p.skillLevel?.name,
          'joinedAt': p.joinedAt?.toIso8601String(),
        }).toList(),
        'status': updatedLobby.status.name,
        'createdAt': updatedLobby.createdAt?.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(), // Update timestamp
      };

      await _lobbiesCollection.doc(lobbyId).update(lobbyData);

      // Log analytics
      await _analytics.logEvent(
        name: 'lobby_joined',
        parameters: {
          'lobby_id': lobbyId,
          'user_id': user.uid,
          'organizer_id': lobby.organizerId,
          'skill_level': user.skill.effectiveLevel?.name ?? 'unknown',
          'players_count': updatedLobby.players.length,
        },
      );

      print('✅ User ${user.uid} joined lobby $lobbyId');
    } catch (e) {
      print('❌ Error joining lobby: $e');
      throw Exception('Failed to join lobby: $e');
    }
  }

  /// Leave a lobby
  static Future<void> leaveLobby(String lobbyId, String userId) async {
    try {
      final lobbyDoc = await _lobbiesCollection.doc(lobbyId).get();
      
      if (!lobbyDoc.exists) {
        throw Exception('Lobby not found');
      }

      final lobby = LobbyModel.fromJson(lobbyDoc.data() as Map<String, dynamic>);

      // Check if user is in lobby
      if (!lobby.isUserInLobby(userId)) {
        throw Exception('User is not in this lobby');
      }

      // Organizer cannot leave their own lobby
      if (lobby.isUserOrganizer(userId)) {
        throw Exception('Organizer cannot leave their own lobby. Delete the lobby instead.');
      }

      // Update lobby by removing player
      final updatedLobby = lobby.removePlayer(userId);

      // Save to Firestore - manually serialize to avoid custom object issues
      final lobbyData = {
        'id': updatedLobby.id,
        'title': updatedLobby.title,
        'organizerId': updatedLobby.organizerId,
        'organizerName': updatedLobby.organizerName,
        'dateTime': updatedLobby.dateTime.toIso8601String(),
        'clubName': updatedLobby.clubName,
        'courtName': updatedLobby.courtName,
        'skillLevel': updatedLobby.skillLevel.name,
        'matchType': updatedLobby.matchType.name,
        'maxPlayers': updatedLobby.maxPlayers,
        'pricePerPlayer': updatedLobby.pricePerPlayer,
        'notes': updatedLobby.notes,
        'genderPreference': updatedLobby.genderPreference,
        'tags': updatedLobby.tags,
        'players': updatedLobby.players.map((p) => {
          'userId': p.userId,
          'displayName': p.displayName,
          'photoUrl': p.photoUrl,
          'skillLevel': p.skillLevel?.name,
          'joinedAt': p.joinedAt?.toIso8601String(),
        }).toList(),
        'status': updatedLobby.status.name,
        'createdAt': updatedLobby.createdAt?.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(), // Update timestamp
      };

      await _lobbiesCollection.doc(lobbyId).update(lobbyData);

      // Log analytics
      await _analytics.logEvent(
        name: 'lobby_left',
        parameters: {
          'lobby_id': lobbyId,
          'user_id': userId,
          'organizer_id': lobby.organizerId,
          'players_count': updatedLobby.players.length,
        },
      );

      print('✅ User $userId left lobby $lobbyId');
    } catch (e) {
      print('❌ Error leaving lobby: $e');
      throw Exception('Failed to leave lobby: $e');
    }
  }

  /// Delete/Cancel a lobby
  static Future<void> deleteLobby(String lobbyId, String userId) async {
    try {
      final lobbyDoc = await _lobbiesCollection.doc(lobbyId).get();
      
      if (!lobbyDoc.exists) {
        throw Exception('Lobby not found');
      }

      final lobby = LobbyModel.fromJson(lobbyDoc.data() as Map<String, dynamic>);

      // Only organizer can delete
      if (!lobby.canBeCancelledBy(userId)) {
        throw Exception('Only the organizer can delete this lobby');
      }

      // Mark as cancelled instead of actually deleting (for audit trail)
      final updatedLobby = lobby.updateStatus(LobbyStatus.cancelled);
      await _lobbiesCollection.doc(lobbyId).update(updatedLobby.toJson());

      // Log analytics
      await _analytics.logEvent(
        name: 'lobby_cancelled',
        parameters: {
          'lobby_id': lobbyId,
          'organizer_id': userId,
          'players_count': lobby.players.length,
          'reason': 'deleted_by_organizer',
        },
      );

      print('✅ Lobby $lobbyId cancelled by organizer $userId');
    } catch (e) {
      print('❌ Error deleting lobby: $e');
      throw Exception('Failed to delete lobby: $e');
    }
  }

  /// Update lobby status (for match progression)
  static Future<void> updateLobbyStatus(String lobbyId, LobbyStatus status) async {
    try {
      await _lobbiesCollection.doc(lobbyId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent(
        name: 'lobby_status_updated',
        parameters: {
          'lobby_id': lobbyId,
          'new_status': status.name,
        },
      );

      print('✅ Lobby $lobbyId status updated to ${status.name}');
    } catch (e) {
      print('❌ Error updating lobby status: $e');
      throw Exception('Failed to update lobby status: $e');
    }
  }

  /// Check if user can join lobby
  static Future<bool> canUserJoinLobby(String lobbyId, UserModel user) async {
    try {
      final lobby = await getLobby(lobbyId);
      if (lobby == null) return false;

      // Basic checks
      if (!lobby.isJoinable) return false;
      if (lobby.isUserInLobby(user.uid)) return false;

      // Skill level compatibility (optional check)
      if (user.skill.effectiveLevel != null && 
          user.skill.effectiveLevel != lobby.skillLevel) {
        // Allow one level difference
        final userLevelIndex = SkillLevel.values.indexOf(user.skill.effectiveLevel!);
        final lobbyLevelIndex = SkillLevel.values.indexOf(lobby.skillLevel);
        final levelDifference = (userLevelIndex - lobbyLevelIndex).abs();
        
        if (levelDifference > 1) {
          return false; // Too big skill gap
        }
      }

      return true;
    } catch (e) {
      print('❌ Error checking if user can join lobby: $e');
      return false;
    }
  }

  /// Get lobby statistics
  static Future<Map<String, dynamic>> getLobbyStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Get today's lobbies
      final todayLobbies = await getLobbies(
        filters: LobbyFilters(
          startDate: todayStart,
          endDate: todayEnd,
          limit: 100,
        ),
      );

      // Get open lobbies
      final openLobbies = await getLobbies(
        filters: const LobbyFilters(
          status: LobbyStatus.open,
          limit: 100,
        ),
      );

      return {
        'total_today': todayLobbies.length,
        'open_lobbies': openLobbies.length,
        'players_needed': openLobbies.fold<int>(
          0, 
          (sum, lobby) => sum + lobby.availableSpots,
        ),
      };
    } catch (e) {
      print('❌ Error getting lobby stats: $e');
      return {
        'total_today': 0,
        'open_lobbies': 0,
        'players_needed': 0,
      };
    }
  }

  /// Apply client-side filters that Firestore can't handle
  static List<LobbyModel> _applyClientSideFilters(
    List<LobbyModel> lobbies, 
    LobbyFilters filters,
  ) {
    var filtered = lobbies;

    // Search query filter
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchQuery = filters.searchQuery!.toLowerCase();
      filtered = filtered.where((lobby) {
        return lobby.title.toLowerCase().contains(searchQuery) ||
               lobby.clubName.toLowerCase().contains(searchQuery) ||
               lobby.notes?.toLowerCase().contains(searchQuery) == true;
      }).toList();
    }

    // Additional filters can be added here
    
    return filtered;
  }
}