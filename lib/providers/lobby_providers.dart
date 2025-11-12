import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lobby_model.dart';
import '../models/user_model.dart';
import '../services/lobby_service.dart';

/// Provider for streaming lobbies with filters
final lobbiesProvider = StreamProvider.family<List<LobbyModel>, LobbyFilters?>((ref, filters) {
  return LobbyService.streamLobbies(filters: filters);
});

/// Provider for open lobbies (default view)
final openLobbiesProvider = StreamProvider<List<LobbyModel>>((ref) {
  return LobbyService.streamLobbies(
    filters: const LobbyFilters(
      status: LobbyStatus.open,
      limit: 20,
    ),
  );
});

/// Provider for user's lobbies
final userLobbiesProvider = StreamProvider.family<List<LobbyModel>, String>((ref, userId) {
  return LobbyService.streamUserLobbies(userId);
});

/// Provider for getting a single lobby by ID
final lobbyProvider = FutureProvider.family<LobbyModel?, String>((ref, lobbyId) {
  return LobbyService.getLobby(lobbyId);
});

/// Provider for lobby statistics
final lobbyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return LobbyService.getLobbyStats();
});

/// Provider for creating a lobby
final createLobbyProvider = AsyncNotifierProvider<CreateLobbyNotifier, void>(
  CreateLobbyNotifier.new,
);

class CreateLobbyNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial build needed
  }

  Future<String> createLobby(CreateLobbyRequest request, UserModel user) async {
    state = const AsyncLoading();
    try {
      final lobbyId = await LobbyService.createLobby(request, user);
      state = const AsyncData(null);
      return lobbyId;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}

/// Provider for joining a lobby
final joinLobbyProvider = AsyncNotifierProvider<JoinLobbyNotifier, void>(
  JoinLobbyNotifier.new,
);

class JoinLobbyNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial build needed
  }

  Future<void> joinLobby(String lobbyId, UserModel user) async {
    state = const AsyncLoading();
    try {
      await LobbyService.joinLobby(lobbyId, user);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }

  Future<void> leaveLobby(String lobbyId, String userId) async {
    state = const AsyncLoading();
    try {
      await LobbyService.leaveLobby(lobbyId, userId);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
      rethrow;
    }
  }
}