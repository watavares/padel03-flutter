import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';
import 'create_lobby_screen.dart';

// Lobby Model
class PadelLobby {
  final String id;
  final String title;
  final DateTime dateTime;
  final String club;
  final String levelRange;
  final int currentPlayers;
  final int maxPlayers;
  final String status;
  final double price;
  final String format;
  final String notes;
  final String organizerId;
  final List<String> playerIds;

  PadelLobby({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.club,
    required this.levelRange,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.status,
    required this.price,
    required this.format,
    required this.notes,
    required this.organizerId,
    required this.playerIds,
  });
}

// Main Lobbies Screen
class PadelLobbiesScreen extends StatefulWidget {
  const PadelLobbiesScreen({super.key});

  @override
  State<PadelLobbiesScreen> createState() => _PadelLobbiesScreenState();
}

class _PadelLobbiesScreenState extends State<PadelLobbiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filters
  String selectedTimeFilter = 'all';
  String selectedLevelFilter = 'all';
  String selectedClubFilter = 'all';
  
  // Sample data
  List<PadelLobby> allLobbies = [];
  List<PadelLobby> myLobbies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSampleData();
    
    AnalyticsService.logEvent(name: 'lobbies_screen_viewed');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    
    allLobbies = [
      PadelLobby(
        id: '1',
        title: 'Evening Match at Club Central',
        dateTime: now.add(Duration(hours: 2)),
        club: 'Club Central',
        levelRange: '3.0-4.0',
        currentPlayers: 2,
        maxPlayers: 4,
        status: 'Open',
        price: 15.0,
        format: '2v2',
        notes: 'Looking for intermediate players for a fun match!',
        organizerId: 'user123',
        playerIds: ['user123', 'user456'],
      ),
      PadelLobby(
        id: '2',
        title: 'Morning Training Session',
        dateTime: now.add(Duration(days: 1, hours: -2)),
        club: 'Padel Pro Academy',
        levelRange: '4.0-5.0',
        currentPlayers: 4,
        maxPlayers: 4,
        status: 'Full',
        price: 20.0,
        format: '2v2',
        notes: 'Advanced training with coach feedback',
        organizerId: 'user789',
        playerIds: ['user789', 'user101', 'user202', 'user303'],
      ),
      PadelLobby(
        id: '3',
        title: 'Weekend Tournament Prep',
        dateTime: now.add(Duration(days: 2)),
        club: 'Sports Complex Madrid',
        levelRange: '2.5-3.5',
        currentPlayers: 1,
        maxPlayers: 4,
        status: 'Open',
        price: 12.0,
        format: '2v2',
        notes: 'Practice before the weekend tournament',
        organizerId: 'user404',
        playerIds: ['user404'],
      ),
    ];
    
    myLobbies = [allLobbies[0]]; // User is part of first lobby
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade700,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'Lobbies',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshLobbies,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PadelColors.accent,
          labelColor: PadelColors.white,
          unselectedLabelColor: PadelColors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Open'),
            Tab(text: 'My Matches'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOpenLobbies(),
          _buildMyLobbies(),
          _buildHistory(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createLobby,
        backgroundColor: PadelColors.accent,
        foregroundColor: PadelColors.textOnAccent,
        icon: Icon(Icons.add),
        label: Text('Create Lobby'),
      ),
    );
  }

  Widget _buildOpenLobbies() {
    final filteredLobbies = _filterLobbies(allLobbies);
    
    if (filteredLobbies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 64,
              color: PadelColors.grey400,
            ),
            SizedBox(height: PadelSpacing.md),
            Text(
              'No lobbies found',
              style: PadelTypography.h6.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            Text(
              'Try adjusting your filters or create a new lobby',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _refreshLobbies,
      color: PadelColors.accent,
      child: ListView.separated(
        padding: EdgeInsets.all(PadelSpacing.md),
        itemCount: filteredLobbies.length,
        separatorBuilder: (context, index) => SizedBox(height: PadelSpacing.md),
        itemBuilder: (context, index) {
          final lobby = filteredLobbies[index];
          return PadelLobbyCard(
            lobby: lobby,
            onJoin: () => _joinLobby(lobby),
            onLeave: () => _leaveLobby(lobby),
            isJoined: myLobbies.any((l) => l.id == lobby.id),
          );
        },
      ),
    );
  }

  Widget _buildMyLobbies() {
    if (myLobbies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: PadelColors.grey400,
            ),
            SizedBox(height: PadelSpacing.md),
            Text(
              'No upcoming matches',
              style: PadelTypography.h6.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            Text(
              'Join a lobby or create your own match',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: EdgeInsets.all(PadelSpacing.md),
      itemCount: myLobbies.length,
      separatorBuilder: (context, index) => SizedBox(height: PadelSpacing.md),
      itemBuilder: (context, index) {
        final lobby = myLobbies[index];
        return PadelLobbyCard(
          lobby: lobby,
          onLeave: () => _leaveLobby(lobby),
          isJoined: true,
          showActions: true,
        );
      },
    );
  }

  Widget _buildHistory() {
    // TODO: Implement history view
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: PadelColors.grey400,
          ),
          SizedBox(height: PadelSpacing.md),
          Text(
            'Match History',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          SizedBox(height: PadelSpacing.sm),
          Text(
            'Your completed matches will appear here',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<PadelLobby> _filterLobbies(List<PadelLobby> lobbies) {
    return lobbies.where((lobby) {
      // Time filter
      if (selectedTimeFilter != 'all') {
        final now = DateTime.now();
        switch (selectedTimeFilter) {
          case 'today':
            if (!_isSameDay(lobby.dateTime, now)) return false;
            break;
          case 'tomorrow':
            if (!_isSameDay(lobby.dateTime, now.add(Duration(days: 1)))) return false;
            break;
          case 'week':
            if (lobby.dateTime.isAfter(now.add(Duration(days: 7)))) return false;
            break;
        }
      }
      
      // Level filter
      if (selectedLevelFilter != 'all') {
        if (!lobby.levelRange.contains(selectedLevelFilter)) return false;
      }
      
      // Club filter
      if (selectedClubFilter != 'all') {
        if (lobby.club != selectedClubFilter) return false;
      }
      
      return true;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => PadelFilterDialog(
        timeFilter: selectedTimeFilter,
        levelFilter: selectedLevelFilter,
        clubFilter: selectedClubFilter,
        onApply: (time, level, club) {
          setState(() {
            selectedTimeFilter = time;
            selectedLevelFilter = level;
            selectedClubFilter = club;
          });
          
          AnalyticsService.logEvent(
            name: 'lobby_filter_applied',
            parameters: {
              'time_filter': time,
              'level_filter': level,
              'club_filter': club,
            },
          );
        },
      ),
    );
  }

  Future<void> _refreshLobbies() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network call
    setState(() {
      _loadSampleData();
    });
    
    AnalyticsService.logEvent(name: 'lobbies_refreshed');
  }

  void _joinLobby(PadelLobby lobby) async {
    if (lobby.currentPlayers >= lobby.maxPlayers) return;
    
    setState(() {
      myLobbies.add(lobby);
      // Update the lobby in allLobbies
      final index = allLobbies.indexWhere((l) => l.id == lobby.id);
      if (index != -1) {
        allLobbies[index] = PadelLobby(
          id: lobby.id,
          title: lobby.title,
          dateTime: lobby.dateTime,
          club: lobby.club,
          levelRange: lobby.levelRange,
          currentPlayers: lobby.currentPlayers + 1,
          maxPlayers: lobby.maxPlayers,
          status: lobby.currentPlayers + 1 >= lobby.maxPlayers ? 'Full' : 'Open',
          price: lobby.price,
          format: lobby.format,
          notes: lobby.notes,
          organizerId: lobby.organizerId,
          playerIds: [...lobby.playerIds, 'current_user'],
        );
      }
    });
    
    await AnalyticsService.logEvent(
      name: 'lobby_joined',
      parameters: {
        'lobby_id': lobby.id,
        'club': lobby.club,
        'level_range': lobby.levelRange,
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully joined the lobby!'),
        backgroundColor: PadelColors.success,
      ),
    );
  }

  void _leaveLobby(PadelLobby lobby) async {
    setState(() {
      myLobbies.removeWhere((l) => l.id == lobby.id);
      // Update the lobby in allLobbies
      final index = allLobbies.indexWhere((l) => l.id == lobby.id);
      if (index != -1) {
        allLobbies[index] = PadelLobby(
          id: lobby.id,
          title: lobby.title,
          dateTime: lobby.dateTime,
          club: lobby.club,
          levelRange: lobby.levelRange,
          currentPlayers: lobby.currentPlayers - 1,
          maxPlayers: lobby.maxPlayers,
          status: 'Open',
          price: lobby.price,
          format: lobby.format,
          notes: lobby.notes,
          organizerId: lobby.organizerId,
          playerIds: lobby.playerIds.where((id) => id != 'current_user').toList(),
        );
      }
    });
    
    await AnalyticsService.logEvent(
      name: 'lobby_left',
      parameters: {
        'lobby_id': lobby.id,
        'club': lobby.club,
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Left the lobby'),
        backgroundColor: PadelColors.warning,
      ),
    );
  }

  void _createLobby() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateLobbyScreen(),
      ),
    );
  }
}

// Lobby Card Widget
class PadelLobbyCard extends StatelessWidget {
  final PadelLobby lobby;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final bool isJoined;
  final bool showActions;

  const PadelLobbyCard({
    super.key,
    required this.lobby,
    this.onJoin,
    this.onLeave,
    this.isJoined = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = lobby.currentPlayers >= lobby.maxPlayers;
    final timeUntilMatch = lobby.dateTime.difference(DateTime.now());
    final isToday = _isSameDay(lobby.dateTime, DateTime.now());
    
    return PadelCard(
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lobby.title,
                  style: PadelTypography.h6.copyWith(
                    color: PadelColors.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PadelBadge(
                text: lobby.status,
                style: _getBadgeStyle(lobby.status),
              ),
            ],
          ),
          SizedBox(height: PadelSpacing.md),
          
          // Time and Date
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: isToday ? PadelColors.accent : PadelColors.textSecondary,
              ),
              SizedBox(width: PadelSpacing.xs),
              Text(
                _formatDateTime(lobby.dateTime),
                style: PadelTypography.bodyMedium.copyWith(
                  color: isToday ? PadelColors.accent : PadelColors.textSecondary,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Spacer(),
              if (timeUntilMatch.inHours > 0)
                Text(
                  'in ${timeUntilMatch.inHours}h',
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
            ],
          ),
          SizedBox(height: PadelSpacing.sm),
          
          // Club and Level
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: PadelColors.textSecondary,
              ),
              SizedBox(width: PadelSpacing.xs),
              Expanded(
                child: Text(
                  lobby.club,
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ),
              PadelChip(
                label: lobby.levelRange,
                size: PadelChipSize.small,
                style: PadelChipStyle.ghost,
                color: PadelColors.secondary,
              ),
            ],
          ),
          
          if (lobby.notes.isNotEmpty) ...[
            SizedBox(height: PadelSpacing.sm),
            Text(
              lobby.notes,
              style: PadelTypography.bodySmall.copyWith(
                color: PadelColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          SizedBox(height: PadelSpacing.md),
          
          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Players and Price
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: PadelColors.textSecondary,
                  ),
                  SizedBox(width: PadelSpacing.xs),
                  Text(
                    '${lobby.currentPlayers}/${lobby.maxPlayers}',
                    style: PadelTypography.bodySmall.copyWith(
                      color: PadelColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: PadelSpacing.md),
                  Icon(
                    Icons.euro,
                    size: 16,
                    color: PadelColors.textSecondary,
                  ),
                  SizedBox(width: PadelSpacing.xs),
                  Text(
                    '${lobby.price.toInt()}',
                    style: PadelTypography.bodySmall.copyWith(
                      color: PadelColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // Action buttons
              if (showActions) ...[
                Row(
                  children: [
                    PadelButton(
                      text: 'Chat',
                      style: PadelButtonStyle.outline,
                      size: PadelButtonSize.small,
                      icon: Icons.chat,
                      onPressed: () {
                        // TODO: Open chat
                      },
                    ),
                    SizedBox(width: PadelSpacing.sm),
                    PadelButton(
                      text: 'Leave',
                      style: PadelButtonStyle.outline,
                      size: PadelButtonSize.small,
                      onPressed: onLeave,
                    ),
                  ],
                ),
              ] else if (!isFull || isJoined) ...[
                PadelButton(
                  text: isJoined ? 'Leave' : 'Join',
                  style: isJoined
                      ? PadelButtonStyle.outline
                      : PadelButtonStyle.accent,
                  size: PadelButtonSize.small,
                  onPressed: isJoined ? onLeave : onJoin,
                ),
              ],
            ],
          ),
        ],
      ),
    ),
    );
  }

  PadelBadgeStyle _getBadgeStyle(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return PadelBadgeStyle.success;
      case 'full':
        return PadelBadgeStyle.secondary;
      case 'in progress':
        return PadelBadgeStyle.warning;
      case 'completed':
        return PadelBadgeStyle.primary;
      default:
        return PadelBadgeStyle.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final matchDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dayStr;
    if (matchDay == today) {
      dayStr = 'Today';
    } else if (matchDay == tomorrow) {
      dayStr = 'Tomorrow';
    } else {
      dayStr = '${dateTime.day}/${dateTime.month}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dayStr at $timeStr';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

// Filter Dialog
class PadelFilterDialog extends StatefulWidget {
  final String timeFilter;
  final String levelFilter;
  final String clubFilter;
  final Function(String, String, String) onApply;

  const PadelFilterDialog({
    super.key,
    required this.timeFilter,
    required this.levelFilter,
    required this.clubFilter,
    required this.onApply,
  });

  @override
  State<PadelFilterDialog> createState() => _PadelFilterDialogState();
}

class _PadelFilterDialogState extends State<PadelFilterDialog> {
  late String selectedTimeFilter;
  late String selectedLevelFilter;
  late String selectedClubFilter;

  @override
  void initState() {
    super.initState();
    selectedTimeFilter = widget.timeFilter;
    selectedLevelFilter = widget.levelFilter;
    selectedClubFilter = widget.clubFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PadelRadius.lg),
      ),
      child: Padding(
        padding: EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Lobbies',
                  style: PadelTypography.h6.copyWith(
                    color: PadelColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear',
                    style: PadelTypography.bodyMedium.copyWith(
                      color: PadelColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: PadelSpacing.lg),
            
            // Time filter
            Text(
              'When',
              style: PadelTypography.labelLarge.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            Wrap(
              spacing: PadelSpacing.sm,
              children: ['all', 'today', 'tomorrow', 'week'].map((filter) {
                return PadelChip(
                  label: _getTimeFilterLabel(filter),
                  isSelected: selectedTimeFilter == filter,
                  onTap: () {
                    setState(() {
                      selectedTimeFilter = filter;
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: PadelSpacing.lg),
            
            // Level filter
            Text(
              'Level',
              style: PadelTypography.labelLarge.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            SizedBox(height: PadelSpacing.sm),
            Wrap(
              spacing: PadelSpacing.sm,
              children: ['all', '1.0-2.5', '2.5-3.5', '3.5-4.5', '4.5+'].map((filter) {
                return PadelChip(
                  label: filter == 'all' ? 'Any Level' : filter,
                  isSelected: selectedLevelFilter == filter,
                  onTap: () {
                    setState(() {
                      selectedLevelFilter = filter;
                    });
                  },
                );
              }).toList(),
            ),
            
            SizedBox(height: PadelSpacing.xl),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: PadelButton(
                    text: 'Cancel',
                    style: PadelButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: PadelButton(
                    text: 'Apply',
                    style: PadelButtonStyle.accent,
                    onPressed: () {
                      widget.onApply(
                        selectedTimeFilter,
                        selectedLevelFilter,
                        selectedClubFilter,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'Any Time';
      case 'today':
        return 'Today';
      case 'tomorrow':
        return 'Tomorrow';
      case 'week':
        return 'This Week';
      default:
        return filter;
    }
  }

  void _clearFilters() {
    setState(() {
      selectedTimeFilter = 'all';
      selectedLevelFilter = 'all';
      selectedClubFilter = 'all';
    });
  }
}

// Create Lobby Screen placeholder
class PadelCreateLobbyScreen extends StatelessWidget {
  final Function(PadelLobby) onLobbyCreated;

  const PadelCreateLobbyScreen({
    super.key,
    required this.onLobbyCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Lobby'),
        backgroundColor: PadelColors.primary,
        foregroundColor: PadelColors.white,
      ),
      body: Center(
        child: Text('Create Lobby Screen - Coming Soon!'),
      ),
    );
  }
}