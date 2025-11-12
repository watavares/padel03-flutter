import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lobby_providers.dart';
import '../providers/auth_providers.dart';
import '../models/lobby_model.dart';
import '../design_system/design_system.dart';
import 'lobby_detail_screen.dart';

class BrowseLobbiesScreen extends ConsumerStatefulWidget {
  const BrowseLobbiesScreen({super.key});

  @override
  ConsumerState<BrowseLobbiesScreen> createState() => _BrowseLobbiesScreenState();
}

class _BrowseLobbiesScreenState extends ConsumerState<BrowseLobbiesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeFilter = 'All Times';
  
  final List<String> _timeFilters = [
    'All Times',
    'Morning',
    'Evening', 
    'Weekend'
  ];

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

  Widget _buildHeader() {
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
                    'Find Matches',
                    style: PadelTypography.h5.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Right: Filter icon
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Container(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            color: Colors.grey.shade50,
            child: _buildTimeFilters(),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabBarView(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTimeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeFilters.map((filter) {
          final isSelected = filter == _selectedTimeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: PadelSpacing.sm),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PadelSpacing.lg,
                  vertical: PadelSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      filter,
                      style: PadelTypography.bodyMedium.copyWith(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: PadelSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300, // Light grey underline
            width: 1,
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Remove default divider
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: PadelColors.accent, // Lime green for selected tab
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent, // Remove default divider
          labelColor: PadelColors.primary, // Dark blue for selected text
          unselectedLabelColor: PadelColors.primary, // Dark blue for unselected text too
          labelStyle: PadelTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: PadelTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'My Matches'),
            Tab(text: 'History'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOpenMatches(),
        _buildMyMatches(),
        _buildMatchHistory(),
      ],
    );
  }

  Widget _buildOpenMatches() {
    final lobbiesAsyncValue = ref.watch(lobbiesProvider(null));
    
    return lobbiesAsyncValue.when(
      data: (lobbies) {
        final filteredLobbies = _filterLobbiesByTime(lobbies);
        if (filteredLobbies.isEmpty) {
          return _buildEmptyState('No open matches found');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          itemCount: filteredLobbies.length,
          itemBuilder: (context, index) {
            return _buildModernLobbyCard(filteredLobbies[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildMyMatches() {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) {
      return _buildEmptyState('Sign in to see your matches');
    }

    final lobbiesAsyncValue = ref.watch(lobbiesProvider(null));
    
    return lobbiesAsyncValue.when(
      data: (lobbies) {
        final myLobbies = lobbies.where((lobby) => 
          lobby.players.any((player) => player.userId == currentUser.uid)
        ).toList();
        
        if (myLobbies.isEmpty) {
          return _buildEmptyState('No matches joined yet');
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          itemCount: myLobbies.length,
          itemBuilder: (context, index) {
            return _buildModernLobbyCard(myLobbies[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildMatchHistory() {
    // For now, show empty state as history needs to be implemented
    return _buildEmptyState('Match history coming soon');
  }

  List<LobbyModel> _filterLobbiesByTime(List<LobbyModel> lobbies) {    
    switch (_selectedTimeFilter) {
      case 'Morning':
        return lobbies.where((lobby) {
          final hour = lobby.dateTime.hour;
          return hour >= 6 && hour < 12;
        }).toList();
      case 'Evening':
        return lobbies.where((lobby) {
          final hour = lobby.dateTime.hour;
          return hour >= 18 && hour <= 23;
        }).toList();
      case 'Weekend':
        return lobbies.where((lobby) {
          final weekday = lobby.dateTime.weekday;
          return weekday == 6 || weekday == 7; // Saturday or Sunday
        }).toList();
      default:
        return lobbies;
    }
  }

  Widget _buildModernLobbyCard(LobbyModel lobby) {
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToLobbyDetail(lobby),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Date/Time on left, Status on right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Date and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: PadelColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_formatDate(lobby.dateTime)}, ${_formatTime(lobby.dateTime)}',
                              style: PadelTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: PadelColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PadelSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: PadelColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                lobby.clubName,
                                style: PadelTypography.bodyMedium.copyWith(
                                  color: PadelColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Right side: Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PadelSpacing.md,
                      vertical: PadelSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: lobby.isJoinable ? PadelColors.accent : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lobby.isJoinable ? 'Open' : 'Full',
                      style: PadelTypography.bodySmall.copyWith(
                        color: lobby.isJoinable ? PadelColors.primary : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: PadelSpacing.lg),
              
              // Divider line
              Container(
                height: 1,
                color: Colors.grey.shade200, // Light grey divider
              ),
              
              const SizedBox(height: PadelSpacing.lg),
              
              // Bottom row: Level on left, Players on right
              Row(
                children: [
                  // Left side: Level
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                        color: PadelColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Level ${lobby.skillLevel.name}',
                        style: PadelTypography.bodyMedium.copyWith(
                          color: PadelColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Right side: Player avatars and count
                  Row(
                    children: [
                      _buildPlayerAvatars(lobby),
                      const SizedBox(width: PadelSpacing.sm),
                      Text(
                        '${lobby.players.length}/${lobby.maxPlayers}',
                        style: PadelTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: PadelColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: PadelSpacing.lg),
              
              // Full-width Join/Leave Match button
              _buildActionButton(lobby),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(LobbyModel lobby) {
    final currentUser = ref.watch(currentUserProvider).value;
    
    if (currentUser == null) {
      return const SizedBox.shrink(); // Don't show button if not signed in
    }

    // Check if user has already joined this lobby
    final hasJoined = lobby.players.any((player) => player.userId == currentUser.uid);
    
    if (hasJoined) {
      // Show Leave Match button with blue background
      return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: PadelColors.primary, // Blue background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _leaveLobby(lobby),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PadelSpacing.md,
                ),
                child: Text(
                  'Leave Match',
                  textAlign: TextAlign.center,
                  style: PadelTypography.labelLarge.copyWith(
                    color: Colors.white, // White text
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (lobby.isJoinable) {
      // Show Join Match button with lime background
      return SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: PadelColors.accent, // Lime background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _quickJoinLobby(lobby),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: PadelSpacing.md,
                ),
                child: Text(
                  'Join Match',
                  textAlign: TextAlign.center,
                  style: PadelTypography.labelLarge.copyWith(
                    color: PadelColors.primary, // Dark blue text
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Lobby is full, don't show button
      return const SizedBox.shrink();
    }
  }

  Widget _buildPlayerAvatars(LobbyModel lobby) {
    // Only show actual joined players, no empty spots
    if (lobby.players.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: lobby.players.asMap().entries.map((entry) {
        final index = entry.key;
        final player = entry.value;
        
        return Container(
          margin: EdgeInsets.only(
            left: index > 0 ? -12 : 0, // Overlap previous circles
          ),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [PadelColors.primary, PadelColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: PadelColors.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: player.photoUrl != null && player.photoUrl!.isNotEmpty
              ? Image.network(
                  player.photoUrl!,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [PadelColors.primary, PadelColors.secondary],
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [PadelColors.primary, PadelColors.secondary],
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 64,
            color: PadelColors.textSecondary,
          ),
          const SizedBox(height: PadelSpacing.lg),
          Text(
            message,
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            'Check back later for new matches',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
          ),
        ],
      ),
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
          const SizedBox(height: PadelSpacing.lg),
          Text(
            'Error loading matches',
            style: PadelTypography.h6.copyWith(
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
        ],
      ),
    );
  }

  void _navigateToLobbyDetail(LobbyModel lobby) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyDetailScreen(lobbyId: lobby.id),
      ),
    );
  }

  void _quickJoinLobby(LobbyModel lobby) {
    showDialog(
      context: context,
      builder: (context) => _buildJoinConfirmationDialog(lobby),
    );
  }

  Widget _buildJoinConfirmationDialog(LobbyModel lobby) {
    return AlertDialog(
      title: const Text('Join Match'),
      content: Text('Join the match at ${lobby.clubName}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await _confirmJoinLobby(lobby);
          },
          child: const Text('Join'),
        ),
      ],
    );
  }

  Future<void> _confirmJoinLobby(LobbyModel lobby) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to join a match')),
      );
      return;
    }

    try {
      await ref.read(joinLobbyProvider.notifier).joinLobby(lobby.id, currentUser);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined match!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join match: $e')),
        );
      }
    }
  }

  Future<void> _leaveLobby(LobbyModel lobby) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    try {
      await ref.read(joinLobbyProvider.notifier).leaveLobby(lobby.id, currentUser.uid);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left match!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave match: $e')),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final lobbyDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (lobbyDate == today) {
      return 'Today';
    } else if (lobbyDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}