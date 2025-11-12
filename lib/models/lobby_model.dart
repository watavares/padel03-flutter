import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'lobby_model.freezed.dart';
part 'lobby_model.g.dart';

/// Lobby status enum
enum LobbyStatus {
  @JsonValue('open')
  open,
  @JsonValue('full') 
  full,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

extension LobbyStatusExtension on LobbyStatus {
  String get displayName {
    switch (this) {
      case LobbyStatus.open:
        return 'Open';
      case LobbyStatus.full:
        return 'Full';
      case LobbyStatus.inProgress:
        return 'In Progress';
      case LobbyStatus.completed:
        return 'Completed';
      case LobbyStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case LobbyStatus.open:
        return 'Players can join this lobby';
      case LobbyStatus.full:
        return 'Lobby is at maximum capacity';
      case LobbyStatus.inProgress:
        return 'Match is currently being played';
      case LobbyStatus.completed:
        return 'Match has finished';
      case LobbyStatus.cancelled:
        return 'Match was cancelled';
    }
  }
}

/// Match type enum
enum MatchType {
  @JsonValue('friendly')
  friendly,
  @JsonValue('competitive')
  competitive,
  @JsonValue('training')
  training,
}

extension MatchTypeExtension on MatchType {
  String get displayName {
    switch (this) {
      case MatchType.friendly:
        return 'Friendly';
      case MatchType.competitive:
        return 'Competitive';
      case MatchType.training:
        return 'Training';
    }
  }

  String get description {
    switch (this) {
      case MatchType.friendly:
        return 'Casual match for fun';
      case MatchType.competitive:
        return 'Serious competitive match';
      case MatchType.training:
        return 'Practice and skill development';
    }
  }
}

/// Player in lobby model
@freezed
class LobbyPlayer with _$LobbyPlayer {
  const factory LobbyPlayer({
    required String userId,
    required String displayName,
    String? photoUrl,
    SkillLevel? skillLevel,
    @TimestampConverter() DateTime? joinedAt,
  }) = _LobbyPlayer;

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) =>
      _$LobbyPlayerFromJson(json);
}

/// Main lobby model
@freezed
class LobbyModel with _$LobbyModel {
  const LobbyModel._();
  
  const factory LobbyModel({
    required String id,
    required String title,
    required String organizerId,
    required String organizerName,
    @TimestampConverter() required DateTime dateTime,
    required String clubName,
    required String courtName,
    required SkillLevel skillLevel,
    required MatchType matchType,
    required int maxPlayers,
    required double pricePerPlayer,
    @Default([]) List<LobbyPlayer> players,
    @Default(LobbyStatus.open) LobbyStatus status,
    String? notes,
    String? genderPreference, // 'male', 'female', 'mixed'
    @Default([]) List<String> tags, // ['beginner-friendly', 'competitive', etc.]
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _LobbyModel;

  factory LobbyModel.fromJson(Map<String, dynamic> json) =>
      _$LobbyModelFromJson(json);

  /// Create a new lobby with default values
  factory LobbyModel.create({
    required String title,
    required String organizerId,
    required String organizerName,
    required DateTime dateTime,
    required String clubName,
    required String courtName,
    required SkillLevel skillLevel,
    required MatchType matchType,
    required int maxPlayers,
    required double pricePerPlayer,
    String? notes,
    String? genderPreference,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return LobbyModel(
      id: '', // Will be set by Firebase
      title: title,
      organizerId: organizerId,
      organizerName: organizerName,
      dateTime: dateTime,
      clubName: clubName,
      courtName: courtName,
      skillLevel: skillLevel,
      matchType: matchType,
      maxPlayers: maxPlayers,
      pricePerPlayer: pricePerPlayer,
      notes: notes,
      genderPreference: genderPreference,
      tags: tags,
      players: [
        // Organizer automatically joins
        LobbyPlayer(
          userId: organizerId,
          displayName: organizerName,
          skillLevel: skillLevel,
          joinedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if lobby has available spots
  bool get hasAvailableSpots => players.length < maxPlayers;

  /// Get number of available spots
  int get availableSpots => maxPlayers - players.length;

  /// Check if user is in this lobby
  bool isUserInLobby(String userId) {
    return players.any((player) => player.userId == userId);
  }

  /// Check if user is the organizer
  bool isUserOrganizer(String userId) {
    return organizerId == userId;
  }

  /// Check if lobby is joinable
  bool get isJoinable {
    return status == LobbyStatus.open && hasAvailableSpots;
  }

  /// Check if lobby can be cancelled/deleted
  bool canBeCancelledBy(String userId) {
    return isUserOrganizer(userId) && 
           (status == LobbyStatus.open || status == LobbyStatus.full);
  }

  /// Get formatted date and time
  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final lobbyDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dayStr;
    if (lobbyDate == today) {
      dayStr = 'Today';
    } else if (lobbyDate == tomorrow) {
      dayStr = 'Tomorrow';
    } else {
      dayStr = '${dateTime.day}/${dateTime.month}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dayStr at $timeStr';
  }

  /// Get skill level display name
  String get skillLevelDisplay => skillLevel.displayName;

  /// Get match type display name
  String get matchTypeDisplay => matchType.displayName;

  /// Get status display name
  String get statusDisplay => status.displayName;

  /// Check if lobby is happening soon (within 2 hours)
  bool get isHappeningSoon {
    final now = DateTime.now();
    final timeDiff = dateTime.difference(now);
    return timeDiff.inHours <= 2 && timeDiff.inMinutes > 0;
  }

  /// Check if lobby is in the past
  bool get isPastDue {
    return dateTime.isBefore(DateTime.now());
  }

  /// Update timestamp helper
  LobbyModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Add player to lobby
  LobbyModel addPlayer(LobbyPlayer player) {
    if (isUserInLobby(player.userId)) {
      return this; // Player already in lobby
    }
    
    final updatedPlayers = [...players, player];
    final newStatus = updatedPlayers.length >= maxPlayers 
        ? LobbyStatus.full 
        : LobbyStatus.open;
    
    return copyWith(
      players: updatedPlayers,
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }

  /// Remove player from lobby
  LobbyModel removePlayer(String userId) {
    final updatedPlayers = players.where((p) => p.userId != userId).toList();
    
    return copyWith(
      players: updatedPlayers,
      status: LobbyStatus.open, // Always open when someone leaves
      updatedAt: DateTime.now(),
    );
  }

  /// Update lobby status
  LobbyModel updateStatus(LobbyStatus newStatus) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
  }
}

/// Lobby query filters
@freezed
class LobbyFilters with _$LobbyFilters {
  const factory LobbyFilters({
    @Default(LobbyStatus.open) LobbyStatus? status,
    SkillLevel? skillLevel,
    MatchType? matchType,
    String? genderPreference,
    DateTime? startDate,
    DateTime? endDate,
    String? clubName,
    @Default(50.0) double maxDistance, // km
    String? searchQuery,
    @Default(20) int limit,
  }) = _LobbyFilters;

  factory LobbyFilters.fromJson(Map<String, dynamic> json) =>
      _$LobbyFiltersFromJson(json);
}

/// Lobby creation request
@freezed
class CreateLobbyRequest with _$CreateLobbyRequest {
  const factory CreateLobbyRequest({
    required String title,
    required DateTime dateTime,
    required String clubName,
    required String courtName,
    required SkillLevel skillLevel,
    required MatchType matchType,
    required int maxPlayers,
    required double pricePerPlayer,
    String? notes,
    String? genderPreference,
    @Default([]) List<String> tags,
  }) = _CreateLobbyRequest;

  factory CreateLobbyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLobbyRequestFromJson(json);
}