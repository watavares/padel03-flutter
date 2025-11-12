import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';
import 'match_detail_screen.dart';

class PadelMatchLogScreen extends StatefulWidget {
  const PadelMatchLogScreen({super.key});

  @override
  State<PadelMatchLogScreen> createState() => _PadelMatchLogScreenState();
}

class _PadelMatchLogScreenState extends State<PadelMatchLogScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Match> _allMatches = [];
  List<Match> _upcomingMatches = [];
  List<Match> _ongoingMatches = [];
  List<Match> _completedMatches = [];
  
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _loadMatches();
    
    AnalyticsService.logEvent(
      name: 'match_log_viewed',
      parameters: {},
    );
  }

  void _setupControllers() {
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      _allMatches = _generateSampleMatches();
      _filterMatches();
    } catch (e) {
      debugPrint('Error loading matches: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterMatches() {
    _upcomingMatches = _allMatches.where((m) => m.status == MatchStatus.waiting).toList();
    _ongoingMatches = _allMatches.where((m) => m.status == MatchStatus.ongoing).toList();
    _completedMatches = _allMatches.where((m) => 
      m.status == MatchStatus.completed || m.status == MatchStatus.disputed).toList();
    
    // Sort by date
    _upcomingMatches.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _ongoingMatches.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    _completedMatches.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<Match> _generateSampleMatches() {
    final now = DateTime.now();
    
    return [
      // Upcoming matches
      Match(
        id: '1',
        title: 'Weekly League Match',
        dateTime: now.add(const Duration(days: 2)),
        court: 'Court 1',
        club: 'Elite Padel Club',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '2', name: 'Carlos Silva', elo: 1280, level: 4),
        ],
        team2: [
          Player(id: '3', name: 'Maria Lopez', elo: 1200, level: 3),
          Player(id: '4', name: 'Juan Martinez', elo: 1220, level: 4),
        ],
        status: MatchStatus.waiting,
      ),
      
      Match(
        id: '2',
        title: 'Championship Semi-Final',
        dateTime: now.add(const Duration(days: 5)),
        court: 'Court 3',
        club: 'Champions Arena',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '5', name: 'Ana Rodriguez', elo: 1300, level: 5),
        ],
        team2: [
          Player(id: '6', name: 'Pedro Santos', elo: 1320, level: 5),
          Player(id: '7', name: 'Luis Garcia', elo: 1280, level: 4),
        ],
        status: MatchStatus.waiting,
      ),
      
      // Ongoing match
      Match(
        id: '3',
        title: 'Friendly Match',
        dateTime: now.subtract(const Duration(minutes: 30)),
        court: 'Court 2',
        club: 'Sports Center',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '8', name: 'Sofia Chen', elo: 1240, level: 4),
        ],
        team2: [
          Player(id: '9', name: 'David Wilson', elo: 1260, level: 4),
          Player(id: '10', name: 'Emma Taylor', elo: 1230, level: 3),
        ],
        status: MatchStatus.ongoing,
        score: Score(
          team1Set1: 6,
          team2Set1: 4,
          team1Set2: 3,
          team2Set2: 6,
        ),
        messages: [
          ChatMessage(
            id: '1',
            senderId: '8',
            senderName: 'Sofia Chen',
            message: 'Great first set! Let\'s keep it up!',
            timestamp: now.subtract(const Duration(minutes: 15)),
          ),
        ],
      ),
      
      // Completed matches
      Match(
        id: '4',
        title: 'Tournament Final',
        dateTime: now.subtract(const Duration(days: 3)),
        court: 'Court 1',
        club: 'Elite Padel Club',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '2', name: 'Carlos Silva', elo: 1280, level: 4),
        ],
        team2: [
          Player(id: '11', name: 'Roberto Kim', elo: 1290, level: 5),
          Player(id: '12', name: 'Laura Brown', elo: 1270, level: 4),
        ],
        status: MatchStatus.completed,
        score: Score(
          team1Set1: 6,
          team2Set1: 4,
          team1Set2: 6,
          team2Set2: 3,
          isConfirmed: true,
        ),
        eloChange: 18,
        xpGained: 75,
        isWinner: true,
        messages: [
          ChatMessage(
            id: '2',
            senderId: '11',
            senderName: 'Roberto Kim',
            message: 'Excellent game! Well played everyone.',
            timestamp: now.subtract(const Duration(days: 3, hours: 1)),
          ),
          ChatMessage(
            id: '3',
            senderId: '1',
            senderName: 'You',
            message: 'Thanks! Great match, looking forward to the next one.',
            timestamp: now.subtract(const Duration(days: 3, hours: 1)),
          ),
        ],
      ),
      
      Match(
        id: '5',
        title: 'League Match',
        dateTime: now.subtract(const Duration(days: 7)),
        court: 'Court 2',
        club: 'City Sports',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '13', name: 'Alex Johnson', elo: 1220, level: 3),
        ],
        team2: [
          Player(id: '14', name: 'Nina Patel', elo: 1260, level: 4),
          Player(id: '15', name: 'Tom Anderson', elo: 1240, level: 4),
        ],
        status: MatchStatus.completed,
        score: Score(
          team1Set1: 4,
          team2Set1: 6,
          team1Set2: 3,
          team2Set2: 6,
          isConfirmed: true,
        ),
        eloChange: -12,
        xpGained: 25,
        isWinner: false,
      ),
      
      // Disputed match
      Match(
        id: '6',
        title: 'Club Championship',
        dateTime: now.subtract(const Duration(days: 10)),
        court: 'Court 3',
        club: 'Pro Padel Center',
        team1: [
          Player(id: '1', name: 'You', elo: 1250, level: 4),
          Player(id: '16', name: 'Mike Davis', elo: 1270, level: 4),
        ],
        team2: [
          Player(id: '17', name: 'Sara White', elo: 1280, level: 5),
          Player(id: '18', name: 'Chris Lee', elo: 1250, level: 4),
        ],
        status: MatchStatus.disputed,
        score: Score(
          team1Set1: 6,
          team2Set1: 4,
          team1Set2: 6,
          team2Set2: 7,
          team1Set3: 6,
          team2Set3: 4,
          needsOpponentConfirmation: true,
        ),
        messages: [
          ChatMessage(
            id: '4',
            senderId: 'system',
            senderName: 'System',
            message: 'Score is under review by tournament officials.',
            timestamp: now.subtract(const Duration(days: 10)),
            isSystemMessage: true,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: PadelColors.background,
      appBar: AppBar(
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Match Log',
          style: PadelTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('All'),
                  if (_allMatches.isNotEmpty)
                    PadelBadge(
                      text: _allMatches.length.toString(),
                      style: PadelBadgeStyle.primary,
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Upcoming'),
                  if (_upcomingMatches.isNotEmpty)
                    PadelBadge(
                      text: _upcomingMatches.length.toString(),
                      style: PadelBadgeStyle.warning,
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Live'),
                  if (_ongoingMatches.isNotEmpty)
                    PadelBadge(
                      text: _ongoingMatches.length.toString(),
                      style: PadelBadgeStyle.success,
                    ),
                ],
              ),
            ),
            Tab(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('History'),
                  if (_completedMatches.isNotEmpty)
                    PadelBadge(
                      text: _completedMatches.length.toString(),
                      style: PadelBadgeStyle.info,
                    ),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: PadelTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(PadelColors.primary),
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMatchList(_allMatches, 'No matches found'),
        _buildMatchList(_upcomingMatches, 'No upcoming matches'),
        _buildMatchList(_ongoingMatches, 'No live matches'),
        _buildMatchList(_completedMatches, 'No match history'),
      ],
    );
  }

  Widget _buildMatchList(List<Match> matches, String emptyMessage) {
    if (matches.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: PadelColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(PadelSpacing.md),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return _buildMatchCard(match, index);
        },
      ),
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
          const SizedBox(height: PadelSpacing.md),
          Text(
            message,
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            'New matches will appear here',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Match match, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PadelSpacing.md),
        child: PadelCard(
          onTap: () => _navigateToMatchDetail(match),
          child: Padding(
            padding: const EdgeInsets.all(PadelSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMatchHeader(match),
                const SizedBox(height: PadelSpacing.md),
                _buildMatchInfo(match),
                const SizedBox(height: PadelSpacing.md),
                _buildTeamsPreview(match),
                if (match.score != null) ...[
                  const SizedBox(height: PadelSpacing.md),
                  _buildScorePreview(match.score!),
                ],
                const SizedBox(height: PadelSpacing.md),
                _buildMatchActions(match),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchHeader(Match match) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                match.title,
                style: PadelTypography.h6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PadelColors.primary,
                ),
              ),
              const SizedBox(height: PadelSpacing.xs),
              Text(
                '${_formatDate(match.dateTime)} at ${_formatTime(match.dateTime)}',
                style: PadelTypography.bodyMedium.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(match.status),
      ],
    );
  }

  Widget _buildMatchInfo(Match match) {
    return Row(
      children: [
        Icon(Icons.location_on, color: PadelColors.textSecondary, size: 16),
        const SizedBox(width: PadelSpacing.xs),
        Expanded(
          child: Text(
            '${match.court} - ${match.club}',
            style: PadelTypography.caption.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
        ),
        if (match.messages.isNotEmpty) ...[
          Icon(Icons.chat_bubble, color: PadelColors.info, size: 16),
          const SizedBox(width: PadelSpacing.xs),
          Text(
            '${match.messages.length}',
            style: PadelTypography.caption.copyWith(
              color: PadelColors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTeamsPreview(Match match) {
    return Row(
      children: [
        Expanded(
          child: _buildTeamPreview('Team 1', match.team1),
        ),
        Container(
          width: 2,
          height: 40,
          color: PadelColors.grey200,
          margin: const EdgeInsets.symmetric(horizontal: PadelSpacing.md),
        ),
        Expanded(
          child: _buildTeamPreview('Team 2', match.team2),
        ),
      ],
    );
  }

  Widget _buildTeamPreview(String teamName, List<Player> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: PadelTypography.caption.copyWith(
            color: PadelColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PadelSpacing.xs),
        ...players.take(2).map((player) => Text(
          player.name,
          style: PadelTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        )),
      ],
    );
  }

  Widget _buildScorePreview(Score score) {
    return Container(
      padding: const EdgeInsets.all(PadelSpacing.md),
      decoration: BoxDecoration(
        color: PadelColors.grey100,
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_score, color: PadelColors.primary, size: 20),
          const SizedBox(width: PadelSpacing.sm),
          Text(
            score.displayScore,
            style: PadelTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: PadelColors.primary,
            ),
          ),
          if (score.isConfirmed) ...[
            const SizedBox(width: PadelSpacing.sm),
            Icon(Icons.check_circle, color: PadelColors.success, size: 16),
          ] else if (score.needsOpponentConfirmation) ...[
            const SizedBox(width: PadelSpacing.sm),
            Icon(Icons.schedule, color: PadelColors.warning, size: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchActions(Match match) {
    switch (match.status) {
      case MatchStatus.waiting:
        return Row(
          children: [
            Expanded(
              child: PadelButton(
                text: 'View Details',
                onPressed: () => _navigateToMatchDetail(match),
                style: PadelButtonStyle.outline,
                size: PadelButtonSize.small,
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
            Expanded(
              child: PadelButton(
                text: 'Start Match',
                onPressed: () => _quickStartMatch(match),
                style: PadelButtonStyle.primary,
                size: PadelButtonSize.small,
                icon: Icons.play_arrow,
              ),
            ),
          ],
        );
        
      case MatchStatus.ongoing:
        return Row(
          children: [
            Expanded(
              child: PadelButton(
                text: 'Open Match',
                onPressed: () => _navigateToMatchDetail(match),
                style: PadelButtonStyle.primary,
                size: PadelButtonSize.small,
                icon: Icons.sports_tennis,
              ),
            ),
            if (match.score == null) ...[
              const SizedBox(width: PadelSpacing.sm),
              PadelButton(
                text: 'Score',
                onPressed: () => _quickAddScore(match),
                style: PadelButtonStyle.secondary,
                size: PadelButtonSize.small,
                icon: Icons.add,
              ),
            ],
          ],
        );
        
      case MatchStatus.completed:
        return Row(
          children: [
            Expanded(
              child: PadelButton(
                text: 'View Result',
                onPressed: () => _navigateToMatchDetail(match),
                style: PadelButtonStyle.outline,
                size: PadelButtonSize.small,
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
            PadelButton(
              text: 'Share',
              onPressed: () => _shareMatch(match),
              style: PadelButtonStyle.secondary,
              size: PadelButtonSize.small,
              icon: Icons.share,
            ),
            const SizedBox(width: PadelSpacing.sm),
            PadelButton(
              text: 'Rematch',
              onPressed: () => _requestRematch(match),
              style: PadelButtonStyle.primary,
              size: PadelButtonSize.small,
              icon: Icons.refresh,
            ),
          ],
        );
        
      case MatchStatus.disputed:
        return Row(
          children: [
            Expanded(
              child: PadelButton(
                text: 'Review Dispute',
                onPressed: () => _navigateToMatchDetail(match),
                style: PadelButtonStyle.secondary,
                size: PadelButtonSize.small,
                icon: Icons.gavel,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStatusBadge(MatchStatus status) {
    PadelBadgeStyle style;
    String text;
    
    switch (status) {
      case MatchStatus.waiting:
        style = PadelBadgeStyle.warning;
        text = 'Upcoming';
        break;
      case MatchStatus.ongoing:
        style = PadelBadgeStyle.success;
        text = 'Live';
        break;
      case MatchStatus.completed:
        style = PadelBadgeStyle.info;
        text = 'Completed';
        break;
      case MatchStatus.disputed:
        style = PadelBadgeStyle.error;
        text = 'Disputed';
        break;
    }

    return PadelBadge(text: text, style: style);
  }

  // Action Methods
  void _navigateToMatchDetail(Match match) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PadelMatchDetailScreen(match: match),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    AnalyticsService.logEvent(
      name: 'match_detail_opened',
      parameters: {
        'match_id': match.id,
        'match_status': match.status.name,
        'source': 'match_log',
      },
    );
  }

  void _quickStartMatch(Match match) {
    AnalyticsService.logEvent(
      name: 'match_quick_started',
      parameters: {'match_id': match.id},
    );

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Match "${match.title}" started!'),
        backgroundColor: PadelColors.success,
      ),
    );

    // Update match status and reload
    setState(() {
      final index = _allMatches.indexWhere((m) => m.id == match.id);
      if (index != -1) {
        _allMatches[index] = Match(
          id: match.id,
          title: match.title,
          dateTime: match.dateTime,
          court: match.court,
          club: match.club,
          team1: match.team1,
          team2: match.team2,
          status: MatchStatus.ongoing,
          score: match.score,
          messages: match.messages,
        );
        _filterMatches();
      }
    });
  }

  void _quickAddScore(Match match) {
    _navigateToMatchDetail(match);
  }

  void _shareMatch(Match match) {
    AnalyticsService.logEvent(
      name: 'match_shared',
      parameters: {
        'match_id': match.id,
        'source': 'match_log',
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Match details shared!')),
    );
  }

  void _requestRematch(Match match) {
    AnalyticsService.logEvent(
      name: 'rematch_requested',
      parameters: {
        'match_id': match.id,
        'source': 'match_log',
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rematch request sent!')),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Matches',
          style: PadelTypography.h6.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter options coming soon!',
              style: PadelTypography.bodyMedium,
            ),
          ],
        ),
        actions: [
          PadelButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
            style: PadelButtonStyle.outline,
            size: PadelButtonSize.small,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}