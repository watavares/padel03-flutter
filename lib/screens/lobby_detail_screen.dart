import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lobby_model.dart';
import '../models/user_model.dart';
import '../providers/lobby_providers.dart';
import '../providers/auth_providers.dart';
import '../design_system/design_system.dart';
import '../design_system/modern_components.dart';

// New Enhanced Lobby Detail Screen (v2)
class LobbyDetailScreen extends ConsumerStatefulWidget {
  final String lobbyId;

  const LobbyDetailScreen({
    super.key,
    required this.lobbyId,
  });

  @override
  ConsumerState<LobbyDetailScreen> createState() => _LobbyDetailScreenState();
}

class _LobbyDetailScreenState extends ConsumerState<LobbyDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Only Details and Chat
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyAsyncValue = ref.watch(lobbyProvider(widget.lobbyId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildFixedTopBar(lobbyAsyncValue),
          _buildTabsSection(),
          Expanded(
            child: lobbyAsyncValue.when(
              data: (lobby) => lobby == null
                  ? _buildNotFoundState()
                  : _buildContent(lobby, currentUser),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedTopBar(AsyncValue<LobbyModel?> lobbyAsyncValue) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF0B2748), // Navy blue
            const Color(0xFF003C5C), // Deep cyan
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back arrow
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              
              // Center: Match date/time
              Expanded(
                child: lobbyAsyncValue.when(
                  data: (lobby) => lobby != null
                      ? Text(
                          _formatDateTime(lobby.dateTime),
                          style: PadelTypography.h6.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              
              // Status badge
              lobbyAsyncValue.when(
                data: (lobby) => lobby != null
                    ? _buildStatusBadge(lobby)
                    : const SizedBox(width: 48),
                loading: () => const SizedBox(width: 48),
                error: (_, __) => const SizedBox(width: 48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(LobbyModel lobby) {
    final now = DateTime.now();
    final matchTime = lobby.dateTime;
    final isOngoing = now.isAfter(matchTime) && now.isBefore(matchTime.add(const Duration(hours: 2)));
    final isFinished = now.isAfter(matchTime.add(const Duration(hours: 2)));
    
    Color backgroundColor;
    Color textColor;
    String text;
    
    if (isFinished) {
      backgroundColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
      text = 'Finished';
    } else if (isOngoing) {
      backgroundColor = PadelColors.primary;
      textColor = Colors.white;
      text = 'Ongoing';
    } else if (lobby.isJoinable) {
      backgroundColor = PadelColors.accent;
      textColor = Colors.white;
      text = 'Open';
    } else {
      backgroundColor = Colors.grey.shade300;
      textColor = Colors.grey.shade700;
      text = 'Full';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: PadelTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: PadelColors.accent, // Lime green underline
        indicatorWeight: 3,
        labelColor: PadelColors.primary,
        unselectedLabelColor: PadelColors.textSecondary,
        labelStyle: PadelTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: PadelTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Chat'),
        ],
      ),
    );
  }

  Widget _buildContent(LobbyModel lobby, UserModel? currentUser) {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(lobby, currentUser),
              _buildChatTab(lobby, currentUser),
            ],
          ),
        ),
        _buildBottomActionButton(lobby, currentUser),
      ],
    );
  }

  Widget _buildDetailsTab(LobbyModel lobby, UserModel? currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchOverviewCard(lobby),
          const SizedBox(height: 16),
          _buildAboutMatchCard(lobby),
          const SizedBox(height: 16),
          _buildPlayersSection(lobby, currentUser),
          const SizedBox(height: 16),
          _buildClubInfoCard(lobby),
          const SizedBox(height: 100), // Extra space for bottom button
        ],
      ),
    );
  }

  Widget _buildMatchOverviewCard(LobbyModel lobby) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Overview',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow(
            Icons.people_outline,
            'Level Range',
            '${lobby.skillLevel.name} – ${lobby.skillLevel.name}',
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Date & Time',
            _formatDateTime(lobby.dateTime),
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            Icons.sports_tennis_outlined,
            'Court',
            lobby.courtName,
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow(
            Icons.euro_outlined,
            'Price per player',
            '€${lobby.pricePerPlayer.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: PadelColors.accent,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: PadelTypography.bodyMedium.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutMatchCard(LobbyModel lobby) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About This Match',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lobby.notes?.isNotEmpty == true 
                ? lobby.notes! 
                : 'Evening match at one of the best clubs. All levels welcome within range!',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: PadelColors.accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Venue Location',
                style: PadelTypography.bodySmall.copyWith(
                  color: PadelColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection(LobbyModel lobby, UserModel? currentUser) {
    final isUserJoined = currentUser != null && 
        lobby.players.any((player) => player.userId == currentUser.uid);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Players (${lobby.players.length}/${lobby.maxPlayers})',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Current players
          ...lobby.players.map((player) => _buildPlayerCard(
            player, 
            player.userId == lobby.organizerId,
          )),
          
          // Available slots
          if (lobby.availableSpots > 0)
            ...List.generate(
              lobby.availableSpots,
              (index) => _buildEmptySlotCard(currentUser != null && !isUserJoined),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(LobbyPlayer player, bool isHost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHost ? PadelColors.accent.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHost ? PadelColors.accent.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isHost 
                    ? [PadelColors.accent, PadelColors.accent.withOpacity(0.7)]
                    : [PadelColors.primary, PadelColors.secondary],
              ),
            ),
            child: ClipOval(
              child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                  ? Image.network(
                      player.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.displayName,
                      style: PadelTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PadelColors.primary,
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PadelColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Host',
                          style: PadelTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  'Level ${player.skillLevel?.displayName ?? 'Unknown'}',
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Status icon
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlotCard(bool canJoin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canJoin ? PadelColors.accent.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canJoin ? PadelColors.accent.withOpacity(0.3) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Plus icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canJoin ? PadelColors.accent.withOpacity(0.2) : Colors.grey.shade200,
            ),
            child: Icon(
              Icons.add,
              color: canJoin ? PadelColors.accent : Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          Text(
            canJoin ? 'Join this match' : 'Waiting for player...',
            style: PadelTypography.bodyLarge.copyWith(
              color: canJoin ? PadelColors.accent : Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubInfoCard(LobbyModel lobby) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Club Info',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.sports_tennis,
                color: PadelColors.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                lobby.clubName,
                style: PadelTypography.bodyLarge.copyWith(
                  color: PadelColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: PadelColors.accent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lobby.clubName, // Placeholder for full address
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Open in maps functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening in Maps...')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: PadelColors.primary,
                side: BorderSide(color: PadelColors.primary, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Open in Maps'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(LobbyModel lobby, UserModel? currentUser) {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Pinned match rules at top
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PadelColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PadelColors.accent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin,
                  color: PadelColors.accent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Match Rules: Be on time, bring your own racket, and have fun! 🎾',
                    style: PadelTypography.bodySmall.copyWith(
                      color: PadelColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages area
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: PadelTypography.bodyLarge.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Be the first to say hello!',
                    style: PadelTypography.bodyMedium.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: PadelColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Send message functionality
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(LobbyModel lobby, UserModel? currentUser) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final isUserJoined = lobby.players.any((player) => player.userId == currentUser.uid);
    final now = DateTime.now();
    final isFinished = now.isAfter(lobby.dateTime.add(const Duration(hours: 2)));
    
    if (isFinished) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    String text;
    VoidCallback? onPressed;
    
    if (isUserJoined) {
      backgroundColor = Colors.red;
      textColor = Colors.white;
      text = 'Leave Match';
      onPressed = () => _leaveLobby(lobby, currentUser);
    } else if (lobby.isJoinable) {
      backgroundColor = PadelColors.accent;
      textColor = Colors.white;
      text = 'Join Match';
      onPressed = () => _joinLobby(lobby, currentUser);
    } else {
      backgroundColor = Colors.grey.shade400;
      textColor = Colors.white;
      text = 'Match Full';
      onPressed = null;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              text,
              style: PadelTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final lobbyDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (lobbyDate == today) {
      dateStr = 'Today';
    } else if (lobbyDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr, $timeStr';
  }

  Future<void> _joinLobby(LobbyModel lobby, UserModel currentUser) async {
    try {
      await ref.read(joinLobbyProvider.notifier).joinLobby(lobby.id, currentUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the match! 🎾'),
            backgroundColor: Colors.green,
          ),
        );
        // Auto scroll to players section would go here
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join match: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _leaveLobby(LobbyModel lobby, UserModel currentUser) async {
    try {
      await ref.read(joinLobbyProvider.notifier).leaveLobby(lobby.id, currentUser.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully left the match'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave match: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading match details',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Match not found',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Original Lobby Detail Screen (v1) - Preserved for fallback
class LobbyDetailScreenV1 extends ConsumerStatefulWidget {
  final String lobbyId;

  const LobbyDetailScreenV1({
    super.key,
    required this.lobbyId,
  });

  @override
  ConsumerState<LobbyDetailScreenV1> createState() => _LobbyDetailScreenV1State();
}

class _LobbyDetailScreenV1State extends ConsumerState<LobbyDetailScreenV1>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lobbyAsyncValue = ref.watch(lobbyProvider(widget.lobbyId));
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: lobbyAsyncValue.when(
              data: (lobby) => lobby == null
                  ? _buildNotFoundState()
                  : _buildLobbyContent(lobby, currentUser),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Back button and title
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Lobby Details',
                    style: PadelTypography.h5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Right: Share icon
              IconButton(
                icon: Icon(Icons.share, color: Colors.grey.shade700),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: PadelColors.error,
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Error loading lobby',
            style: PadelTypography.h5.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            error.toString(),
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PadelSpacing.lg),
          PadelButton(
            text: 'Retry',
            onPressed: () => ref.refresh(lobbyProvider(widget.lobbyId)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 64,
            color: PadelColors.grey400,
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'Lobby not found',
            style: PadelTypography.h5.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            'This lobby may have been deleted or the link is incorrect.',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PadelSpacing.lg),
          PadelButton(
            text: 'Go Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyContent(LobbyModel lobby, UserModel? currentUser) {
    final isUserInLobby = currentUser != null && lobby.isUserInLobby(currentUser.uid);
    final isOrganizer = currentUser != null && lobby.isUserOrganizer(currentUser.uid);

    return Column(
      children: [
        // Lobby Header Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PadelColors.primary,
                PadelColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            child: PadelModernCard(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Level
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lobby.title,
                            style: PadelTypography.h5.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PadelSpacing.md,
                            vertical: PadelSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: PadelColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            lobby.skillLevelDisplay,
                            style: PadelTypography.labelLarge.copyWith(
                              color: PadelColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PadelSpacing.lg),
                    
                    // Host Info
                    _buildInfoRow(
                      Icons.person_outline,
                      'Host',
                      lobby.organizerName,
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    
                    // Date & Time
                    _buildInfoRow(
                      Icons.access_time_outlined,
                      'Date & Time',
                      lobby.formattedDateTime,
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    
                    // Location
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      'Location',
                      '${lobby.clubName} - ${lobby.courtName}',
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    
                    // Players
                    _buildInfoRow(
                      Icons.group_outlined,
                      'Players',
                      '${lobby.players.length}/${lobby.maxPlayers} joined (${lobby.availableSpots} spots left)',
                    ),
                    
                    const SizedBox(height: PadelSpacing.md),
                    _buildInfoRow(
                      Icons.euro_outlined,
                      'Price',
                      '€${lobby.pricePerPlayer.toStringAsFixed(2)} per person',
                    ),
                    
                    const SizedBox(height: PadelSpacing.lg),
                    
                    // Join/Leave Button
                    if (currentUser != null && !isOrganizer) ...[
                      SizedBox(
                        width: double.infinity,
                        child: PadelModernButton(
                          text: isUserInLobby ? 'Leave Lobby' : 'Join Lobby',
                          onPressed: lobby.isJoinable || isUserInLobby
                              ? () => _handleJoinLeave(lobby, currentUser, isUserInLobby)
                              : null,
                          style: isUserInLobby 
                            ? PadelButtonStyle.outline 
                            : PadelButtonStyle.primary,
                        ),
                      ),
                    ] else if (isOrganizer) ...[
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(PadelSpacing.md),
                          decoration: BoxDecoration(
                            color: PadelColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: PadelColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: PadelSpacing.sm),
                              Text(
                                'You are the organizer',
                                style: PadelTypography.labelLarge.copyWith(
                                  color: PadelColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(PadelSpacing.md),
                          decoration: BoxDecoration(
                            color: PadelColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sign in to join this lobby',
                            style: PadelTypography.labelLarge.copyWith(
                              color: PadelColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: PadelColors.primary,
            unselectedLabelColor: PadelColors.textSecondary,
            indicatorColor: PadelColors.primary,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Chat'),
              Tab(text: 'Players'),
            ],
          ),
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(lobby),
              _buildChatTab(lobby),
              _buildPlayersTab(lobby),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleJoinLeave(LobbyModel lobby, UserModel currentUser, bool isUserInLobby) async {
    try {
      if (isUserInLobby) {
        await ref.read(joinLobbyProvider.notifier).leaveLobby(lobby.id, currentUser.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Left the lobby successfully')),
          );
        }
      } else {
        await ref.read(joinLobbyProvider.notifier).joinLobby(lobby.id, currentUser);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Joined the lobby successfully!')),
          );
        }
      }
      // Refresh the lobby data
      ref.invalidate(lobbyProvider(widget.lobbyId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: PadelColors.primary,
          size: 20,
        ),
        const SizedBox(width: PadelSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PadelTypography.labelMedium.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              const SizedBox(height: PadelSpacing.xs),
              Text(
                value,
                style: PadelTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(LobbyModel lobby) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lobby.notes != null && lobby.notes!.isNotEmpty) ...[
            PadelModernCard(
              child: Padding(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes from Host',
                      style: PadelTypography.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Text(
                      lobby.notes!,
                      style: PadelTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
          ],
          
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Type',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(PadelSpacing.md),
                    decoration: BoxDecoration(
                      color: PadelColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          lobby.matchType == MatchType.friendly 
                            ? Icons.sports_handball 
                            : Icons.emoji_events,
                          color: PadelColors.primary,
                        ),
                        const SizedBox(width: PadelSpacing.md),
                        Text(
                          lobby.matchTypeDisplay,
                          style: PadelTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (lobby.genderPreference != null) ...[
            const SizedBox(height: PadelSpacing.lg),
            PadelModernCard(
              child: Padding(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender Preference',
                      style: PadelTypography.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(PadelSpacing.md),
                      decoration: BoxDecoration(
                        color: PadelColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            lobby.genderPreference == 'male' 
                              ? Icons.male
                              : lobby.genderPreference == 'female'
                                ? Icons.female
                                : Icons.group,
                            color: PadelColors.accent,
                          ),
                          const SizedBox(width: PadelSpacing.md),
                          Text(
                            lobby.genderPreference!.toUpperCase(),
                            style: PadelTypography.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (lobby.tags.isNotEmpty) ...[
            const SizedBox(height: PadelSpacing.lg),
            PadelModernCard(
              child: Padding(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: PadelTypography.h6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Wrap(
                      spacing: PadelSpacing.sm,
                      runSpacing: PadelSpacing.sm,
                      children: lobby.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PadelSpacing.md,
                          vertical: PadelSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: PadelColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: PadelTypography.labelMedium.copyWith(
                            color: PadelColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: PadelSpacing.lg),
          
          PadelModernCard(
            child: Padding(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Court Rules',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: PadelSpacing.md),
                  _buildRuleItem('Arrive 15 minutes before match time'),
                  _buildRuleItem('Bring your own racket'),
                  _buildRuleItem('Balls provided by the club'),
                  _buildRuleItem('Cancellation 24h in advance'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PadelSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: PadelColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: PadelSpacing.md),
          Expanded(
            child: Text(
              rule,
              style: PadelTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(LobbyModel lobby) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            children: [
              _buildChatMessage(
                lobby.organizerName,
                'Hey everyone! Looking forward to the match!',
                '10:30 AM',
                isHost: true,
              ),
              _buildChatMessage(
                'Maria Santos',
                'Same here! What level rackets should we bring?',
                '10:35 AM',
              ),
              _buildChatMessage(
                lobby.organizerName,
                'Any level is fine, the club also has rentals available',
                '10:37 AM',
                isHost: true,
              ),
              // Add placeholder for now - real chat would come from a separate chat service
              Container(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                margin: const EdgeInsets.only(top: PadelSpacing.lg),
                decoration: BoxDecoration(
                  color: PadelColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Chat feature coming soon! For now, coordinate with other players directly.',
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: PadelColors.grey100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: PadelSpacing.lg,
                      vertical: PadelSpacing.md,
                    ),
                  ),
                  enabled: false, // Disabled until chat feature is implemented
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: PadelColors.grey300, // Disabled color
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: null, // Disabled until chat feature is implemented
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(String name, String message, String time, {bool isHost = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PadelSpacing.md),
      child: PadelModernCard(
        child: Padding(
          padding: const EdgeInsets.all(PadelSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: PadelTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isHost ? PadelColors.accent : PadelColors.textPrimary,
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(width: PadelSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PadelSpacing.sm,
                        vertical: PadelSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: PadelColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HOST',
                        style: PadelTypography.caption.copyWith(
                          color: PadelColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    time,
                    style: PadelTypography.caption.copyWith(
                      color: PadelColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PadelSpacing.sm),
              Text(
                message,
                style: PadelTypography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersTab(LobbyModel lobby) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Players Section Header
          Container(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [PadelColors.primary.withOpacity(0.1), PadelColors.secondary.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PadelColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PadelColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: PadelSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Players',
                        style: PadelTypography.h6.copyWith(
                          fontWeight: FontWeight.bold,
                          color: PadelColors.primary,
                        ),
                      ),
                      Text(
                        '${lobby.players.length}/${lobby.maxPlayers} joined • ${lobby.availableSpots} spots available',
                        style: PadelTypography.bodyMedium.copyWith(
                          color: PadelColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PadelSpacing.lg),
          
          // Current Players Grid
          if (lobby.players.isNotEmpty) ...[
            Text(
              'Current Players',
              style: PadelTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: PadelColors.textPrimary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: PadelSpacing.md,
                mainAxisSpacing: PadelSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemCount: lobby.players.length,
              itemBuilder: (context, index) {
                final player = lobby.players[index];
                return _buildEnhancedPlayerCard(
                  player,
                  player.userId == lobby.organizerId,
                );
              },
            ),
          ],
          
          // Available Spots
          if (lobby.availableSpots > 0) ...[
            const SizedBox(height: PadelSpacing.xl),
            Text(
              'Available Spots',
              style: PadelTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: PadelColors.textPrimary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: PadelSpacing.md,
                mainAxisSpacing: PadelSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemCount: lobby.availableSpots,
              itemBuilder: (context, index) => _buildEnhancedEmptySlot(lobby),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedPlayerCard(LobbyPlayer player, bool isHost) {
    return PadelModernCard(
      child: Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        decoration: BoxDecoration(
          gradient: isHost 
            ? LinearGradient(
                colors: [PadelColors.accent.withOpacity(0.15), PadelColors.accent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [PadelColors.primary.withOpacity(0.08), PadelColors.secondary.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHost ? PadelColors.accent.withOpacity(0.3) : PadelColors.primary.withOpacity(0.1),
            width: isHost ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Player Avatar with Badge
            Stack(
              alignment: Alignment.center,
              children: [
                // Avatar Background Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isHost 
                        ? [PadelColors.accent, PadelColors.accent.withOpacity(0.7)]
                        : [PadelColors.primary, PadelColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isHost ? PadelColors.accent : PadelColors.primary).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // Avatar Content
                if (player.photoUrl != null && player.photoUrl!.isNotEmpty)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(player.photoUrl!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  )
                else
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: isHost ? PadelColors.accent : PadelColors.primary,
                    ),
                  ),
                // Host Crown Badge
                if (isHost)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: PadelColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: PadelColors.accent.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            
            // Player Name
            Text(
              player.displayName,
              style: PadelTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: PadelSpacing.xs),
            
            // Skill Level Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PadelSpacing.sm,
                vertical: PadelSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isHost ? PadelColors.accent.withOpacity(0.2) : PadelColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHost ? PadelColors.accent.withOpacity(0.3) : PadelColors.primary.withOpacity(0.2),
                ),
              ),
              child: Text(
                player.skillLevel?.displayName ?? 'Unknown',
                style: PadelTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isHost ? PadelColors.accent : PadelColors.primary,
                ),
              ),
            ),
            
            // Host Label
            if (isHost) ...[
              const SizedBox(height: PadelSpacing.xs),
              Text(
                'Host',
                style: PadelTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: PadelColors.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptySlot(LobbyModel lobby) {
    return Consumer(
      builder: (context, ref, child) {
        final isJoining = ref.watch(joinLobbyProvider).isLoading;
        final currentUserAsync = ref.watch(currentUserProvider);
        
        return currentUserAsync.when(
          data: (currentUser) {
            if (currentUser == null) {
              return PadelModernCard(
                child: Container(
                  padding: const EdgeInsets.all(PadelSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: PadelSpacing.md),
                      Text(
                        'Sign In Required',
                        style: PadelTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return PadelModernCard(
              child: InkWell(
                onTap: isJoining ? null : () => _handleJoinClick(ref, currentUser, lobby),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(PadelSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: PadelColors.primary.withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        PadelColors.primary.withOpacity(0.05),
                        PadelColors.secondary.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Join Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isJoining
                              ? [Colors.grey.withOpacity(0.3), Colors.grey.withOpacity(0.1)]
                              : [PadelColors.primary.withOpacity(0.2), PadelColors.secondary.withOpacity(0.3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isJoining 
                              ? Colors.grey.withOpacity(0.4)
                              : PadelColors.primary.withOpacity(0.4),
                            width: 3,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: isJoining ? [] : [
                            BoxShadow(
                              color: PadelColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: isJoining 
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.add,
                              size: 40,
                              color: PadelColors.primary,
                            ),
                      ),
                      const SizedBox(height: PadelSpacing.md),
                      
                      // Join Text
                      Text(
                        isJoining ? 'Joining...' : 'Join Game',
                        style: PadelTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isJoining ? Colors.grey : PadelColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: PadelSpacing.xs),
                      
                      // Tap to join hint
                      if (!isJoining)
                        Text(
                          'Tap to join',
                          style: PadelTypography.caption.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => PadelModernCard(
            child: Container(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stack) => PadelModernCard(
            child: Container(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleJoinClick(WidgetRef ref, UserModel currentUser, LobbyModel lobby) {
    _handleJoinLeave(lobby, currentUser, false);
  }
}
