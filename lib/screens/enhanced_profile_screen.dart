import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';
import '../providers/auth_providers.dart';
import '../models/user_model.dart';
import 'match_detail_screen.dart';

// Profile Models
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String city;
  final int level;
  final int elo;
  final int xp;
  final int totalMatches;
  final int wins;
  final int losses;
  final List<Achievement> achievements;
  final List<Match> recentMatches;
  final DateTime joinedDate;
  final String? bio;
  final String? phoneNumber;
  final List<String> preferredPositions;
  final Map<String, bool> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.city,
    required this.level,
    required this.elo,
    required this.xp,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.achievements,
    required this.recentMatches,
    required this.joinedDate,
    this.bio,
    this.phoneNumber,
    required this.preferredPositions,
    required this.preferences,
  });

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;
  int get xpToNextLevel => ((level + 1) * 1000) - xp;
  double get levelProgress => (xp % 1000) / 1000;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime unlockedDate;
  final bool isRare;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlockedDate,
    this.isRare = false,
  });
}

class PadelEnhancedProfileScreen extends ConsumerStatefulWidget {
  const PadelEnhancedProfileScreen({super.key});

  @override
  ConsumerState<PadelEnhancedProfileScreen> createState() => _PadelEnhancedProfileScreenState();
}

class _PadelEnhancedProfileScreenState extends ConsumerState<PadelEnhancedProfileScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  UserProfile? _userProfile;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    AnalyticsService.logEvent(
      name: 'profile_viewed',
      parameters: {},
    );
  }

  void _setupAnimations() {
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      setState(() {
        _userProfile = _generateSampleProfile();
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  UserProfile _generateSampleProfile() {
    return UserProfile(
      id: 'user_1',
      name: 'Alex Rodriguez',
      email: 'alex.rodriguez@email.com',
      avatarUrl: null,
      city: 'Madrid',
      level: 4,
      elo: 1250,
      xp: 3750,
      totalMatches: 28,
      wins: 18,
      losses: 10,
      joinedDate: DateTime(2023, 3, 15),
      bio: 'Passionate padel player always looking to improve. Love playing competitive matches and meeting new players!',
      phoneNumber: '+34 123 456 789',
      preferredPositions: ['Right Side', 'Left Side'],
      preferences: {
        'notifications_matches': true,
        'notifications_lobbies': true,
        'notifications_achievements': true,
        'public_profile': true,
        'show_stats': true,
        'match_invites': true,
      },
      achievements: [
        Achievement(
          id: 'first_win',
          title: 'First Victory',
          description: 'Win your first match',
          icon: Icons.emoji_events,
          color: PadelColors.accent,
          unlockedDate: DateTime(2023, 3, 20),
        ),
        Achievement(
          id: 'streak_5',
          title: 'Hot Streak',
          description: 'Win 5 matches in a row',
          icon: Icons.local_fire_department,
          color: PadelColors.error,
          unlockedDate: DateTime(2023, 8, 10),
          isRare: true,
        ),
        Achievement(
          id: 'level_4',
          title: 'Intermediate Player',
          description: 'Reach Level 4',
          icon: Icons.star,
          color: PadelColors.primary,
          unlockedDate: DateTime(2023, 9, 5),
        ),
        Achievement(
          id: 'social_butterfly',
          title: 'Social Butterfly',
          description: 'Play with 20 different players',
          icon: Icons.people,
          color: PadelColors.secondary,
          unlockedDate: DateTime(2023, 10, 15),
        ),
      ],
      recentMatches: [
        // Add some recent matches from the sample data
      ],
    );
  }

  UserProfile _generateProfileFromUser(UserModel user) {
    return UserProfile(
      id: user.uid,
      name: user.displayNameOrEmail,
      email: user.email,
      avatarUrl: user.photoUrl,
      city: user.location?.city ?? 'Unknown',
      level: 4, // TODO: Get from user.skill.effectiveLevel or similar
      elo: 1200, // TODO: Calculate from match history
      xp: 1000, // TODO: Calculate from user activity
      totalMatches: 0, // TODO: Get from match history
      wins: 0, // TODO: Get from match history  
      losses: 0, // TODO: Get from match history
      joinedDate: user.createdAt ?? DateTime.now(),
      bio: 'Passionate padel player!', // TODO: Add bio field to UserModel
      phoneNumber: null, // TODO: Add phone field to UserModel
      preferredPositions: ['Right Side'], // TODO: Add to UserModel
      preferences: {
        'notifications_matches': true,
        'notifications_lobbies': true,
        'notifications_achievements': true,
        'public_profile': true,
        'show_stats': true,
        'match_invites': true,
      },
      achievements: [
        Achievement(
          id: 'first_signup',
          title: 'Welcome to PadelArena!',
          description: 'Joined the padel community',
          icon: Icons.star,
          color: PadelColors.accent,
          unlockedDate: user.createdAt ?? DateTime.now(),
        ),
      ],
      recentMatches: [], // TODO: Load from match history
    );
  }

  Widget _buildContentWithProfile(UserProfile profile) {
    // Update the instance variable for other methods
    _userProfile = profile;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildProfileHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: PadelColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PadelColors.primary, PadelColors.secondary],
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: PadelTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareProfile,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return _buildErrorState();
          final profile = _generateProfileFromUser(user);
          return _buildContentWithProfile(profile);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(),
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

  Widget _buildErrorState() {
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
            'Failed to load profile',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.error,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          PadelButton(
            text: 'Retry',
            onPressed: _loadProfile,
            style: PadelButtonStyle.primary,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PadelColors.primary, PadelColors.secondary],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(width: PadelSpacing.lg),
                  Expanded(child: _buildProfileInfo()),
                ],
              ),
              const SizedBox(height: PadelSpacing.lg),
              _buildStatsRow(),
              const SizedBox(height: PadelSpacing.lg),
              _buildLevelProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: _editAvatar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: _userProfile!.avatarUrl != null
                ? NetworkImage(_userProfile!.avatarUrl!)
                : null,
            child: _userProfile!.avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PadelColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _userProfile!.name,
                style: PadelTypography.h5.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
              onPressed: _editProfile,
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.white.withOpacity(0.8), size: 16),
            const SizedBox(width: PadelSpacing.xs),
            Text(
              _userProfile!.city,
              style: PadelTypography.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: PadelSpacing.sm),
        Row(
          children: [
            _buildLevelBadge(),
            const SizedBox(width: PadelSpacing.sm),
            _buildEloBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PadelSpacing.md,
        vertical: PadelSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: PadelColors.accent,
        borderRadius: BorderRadius.circular(PadelSpacing.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: PadelSpacing.xs),
          Text(
            'Level ${_userProfile!.level}',
            style: PadelTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEloBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PadelSpacing.md,
        vertical: PadelSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(PadelSpacing.lg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        'Elo ${_userProfile!.elo}',
        style: PadelTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Matches', _userProfile!.totalMatches.toString()),
        _buildStatItem('Wins', _userProfile!.wins.toString()),
        _buildStatItem('Win Rate', '${_userProfile!.winRate.toStringAsFixed(1)}%'),
        _buildStatItem('XP', _userProfile!.xp.toString()),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: PadelTypography.h6.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: PadelTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${_userProfile!.level} Progress',
              style: PadelTypography.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_userProfile!.xpToNextLevel} XP to Level ${_userProfile!.level + 1}',
              style: PadelTypography.caption.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: PadelSpacing.sm),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(PadelSpacing.sm),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _userProfile!.levelProgress,
            child: Container(
              decoration: BoxDecoration(
                color: PadelColors.accent,
                borderRadius: BorderRadius.circular(PadelSpacing.sm),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Matches'),
          Tab(text: 'Achievements'),
        ],
        labelColor: PadelColors.primary,
        unselectedLabelColor: PadelColors.textSecondary,
        indicatorColor: PadelColors.primary,
        labelStyle: PadelTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildMatchesTab(),
        _buildAchievementsTab(),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBioSection(),
          const SizedBox(height: PadelSpacing.lg),
          _buildQuickStatsCard(),
          const SizedBox(height: PadelSpacing.lg),
          _buildRecentAchievements(),
          const SizedBox(height: PadelSpacing.lg),
          _buildPlayingPreferences(),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'About',
                  style: PadelTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PadelColors.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: PadelColors.textSecondary, size: 20),
                  onPressed: _editBio,
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Text(
              _userProfile!.bio ?? 'No bio available. Tap the edit button to add one!',
              style: PadelTypography.bodyMedium.copyWith(
                color: _userProfile!.bio != null 
                  ? PadelColors.textPrimary 
                  : PadelColors.textSecondary,
                fontStyle: _userProfile!.bio != null 
                  ? FontStyle.normal 
                  : FontStyle.italic,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Icon(Icons.calendar_today, color: PadelColors.textSecondary, size: 16),
                const SizedBox(width: PadelSpacing.sm),
                Text(
                  'Member since ${_formatJoinDate(_userProfile!.joinedDate)}',
                  style: PadelTypography.caption.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Current Streak',
                    '3 wins',
                    Icons.local_fire_department,
                    PadelColors.error,
                  ),
                ),
                Expanded(
                  child: _buildQuickStat(
                    'Best Streak',
                    '7 wins',
                    Icons.emoji_events,
                    PadelColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Avg Score',
                    '6.2',
                    Icons.sports_score,
                    PadelColors.info,
                  ),
                ),
                Expanded(
                  child: _buildQuickStat(
                    'Favorite Court',
                    'Court 1',
                    Icons.sports_tennis,
                    PadelColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(PadelSpacing.md),
      margin: const EdgeInsets.symmetric(horizontal: PadelSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            value,
            style: PadelTypography.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: PadelTypography.caption.copyWith(
              color: PadelColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements() {
    final recentAchievements = _userProfile!.achievements.take(3).toList();
    
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Achievements',
                  style: PadelTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PadelColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: Text(
                    'View All',
                    style: PadelTypography.labelMedium.copyWith(
                      color: PadelColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            ...recentAchievements.map((achievement) => _buildAchievementTile(achievement, isCompact: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingPreferences() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Playing Preferences',
                  style: PadelTypography.h6.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PadelColors.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: PadelColors.textSecondary, size: 20),
                  onPressed: _editPreferences,
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Wrap(
              spacing: PadelSpacing.sm,
              runSpacing: PadelSpacing.sm,
              children: _userProfile!.preferredPositions.map((position) =>
                PadelChip(
                  label: position,
                  isSelected: true,
                  onTap: () {},
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        children: [
          _buildMatchFilters(),
          const SizedBox(height: PadelSpacing.md),
          if (_userProfile!.recentMatches.isEmpty)
            _buildNoMatches()
          else
            ..._userProfile!.recentMatches.map((match) => _buildMatchCard(match)),
        ],
      ),
    );
  }

  Widget _buildMatchFilters() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: PadelButton(
                text: 'All Matches',
                onPressed: () {},
                style: PadelButtonStyle.primary,
                size: PadelButtonSize.small,
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
            Expanded(
              child: PadelButton(
                text: 'Wins Only',
                onPressed: () {},
                style: PadelButtonStyle.outline,
                size: PadelButtonSize.small,
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
            PadelButton(
              text: 'Filter',
              onPressed: _showMatchFilters,
              style: PadelButtonStyle.secondary,
              size: PadelButtonSize.small,
              icon: Icons.filter_list,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoMatches() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.sports_tennis,
              size: 64,
              color: PadelColors.textSecondary,
            ),
            const SizedBox(height: PadelSpacing.md),
            Text(
              'No matches yet',
              style: PadelTypography.h6.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            const SizedBox(height: PadelSpacing.sm),
            Text(
              'Join a lobby to start playing!',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.md),
      child: PadelCard(
        onTap: () => _openMatchDetail(match),
        child: Padding(
          padding: const EdgeInsets.all(PadelSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.title,
                    style: PadelTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (match.isWinner != null)
                    PadelBadge(
                      text: match.isWinner! ? 'Won' : 'Lost',
                      style: match.isWinner! 
                        ? PadelBadgeStyle.success 
                        : PadelBadgeStyle.error,
                    ),
                ],
              ),
              const SizedBox(height: PadelSpacing.sm),
              Text(
                _formatMatchDate(match.dateTime),
                style: PadelTypography.caption.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
              if (match.score != null) ...[
                const SizedBox(height: PadelSpacing.sm),
                Text(
                  match.score!.displayScore,
                  style: PadelTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PadelColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        children: [
          _buildAchievementStats(),
          const SizedBox(height: PadelSpacing.lg),
          ..._userProfile!.achievements.map((achievement) => _buildAchievementTile(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementStats() {
    final totalAchievements = _userProfile!.achievements.length;
    final rareAchievements = _userProfile!.achievements.where((a) => a.isRare).length;
    
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAchievementStat('Total', totalAchievements.toString(), Icons.emoji_events),
            _buildAchievementStat('Rare', rareAchievements.toString(), Icons.diamond),
            _buildAchievementStat('Recent', '2', Icons.new_releases),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: PadelColors.accent, size: 24),
        const SizedBox(height: PadelSpacing.sm),
        Text(
          value,
          style: PadelTypography.h6.copyWith(
            fontWeight: FontWeight.bold,
            color: PadelColors.primary,
          ),
        ),
        Text(
          label,
          style: PadelTypography.caption.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(Achievement achievement, {bool isCompact = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.md),
      child: PadelCard(
        child: Padding(
          padding: EdgeInsets.all(isCompact ? PadelSpacing.md : PadelSpacing.lg),
          child: Row(
            children: [
              Container(
                width: isCompact ? 40 : 48,
                height: isCompact ? 40 : 48,
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(PadelSpacing.sm),
                  border: Border.all(
                    color: achievement.color.withOpacity(0.3),
                    width: achievement.isRare ? 2 : 1,
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.color,
                  size: isCompact ? 20 : 24,
                ),
              ),
              const SizedBox(width: PadelSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          achievement.title,
                          style: (isCompact ? PadelTypography.bodyMedium : PadelTypography.h6).copyWith(
                            fontWeight: FontWeight.bold,
                            color: PadelColors.textPrimary,
                          ),
                        ),
                        if (achievement.isRare) ...[
                          const SizedBox(width: PadelSpacing.sm),
                          PadelBadge(
                            text: 'Rare',
                            style: PadelBadgeStyle.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: PadelSpacing.xs),
                    Text(
                      achievement.description,
                      style: PadelTypography.caption.copyWith(
                        color: PadelColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.xs),
                    Text(
                      'Unlocked ${_formatAchievementDate(achievement.unlockedDate)}',
                      style: PadelTypography.caption.copyWith(
                        color: PadelColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Action Methods
  void _editAvatar() {
    AnalyticsService.logEvent(name: 'profile_avatar_edit_tapped');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Avatar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile() {
    AnalyticsService.logEvent(name: 'profile_edit_tapped');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PadelEditProfileScreen(profile: _userProfile!),
      ),
    );
  }

  void _editBio() {
    AnalyticsService.logEvent(name: 'profile_bio_edit_tapped');
    
    showDialog(
      context: context,
      builder: (context) => PadelEditBioDialog(
        currentBio: _userProfile!.bio ?? '',
        onSave: (newBio) {
          setState(() {
            // Update bio in profile
          });
        },
      ),
    );
  }

  void _editPreferences() {
    AnalyticsService.logEvent(name: 'profile_preferences_edit_tapped');
    // Navigate to preferences edit screen
  }

  void _openSettings() {
    AnalyticsService.logEvent(name: 'profile_settings_opened');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PadelSettingsScreen(profile: _userProfile!),
      ),
    );
  }

  void _shareProfile() {
    AnalyticsService.logEvent(name: 'profile_shared');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile shared!')),
    );
  }

  void _showMatchFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Matches'),
        content: Text('Match filters coming soon!'),
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

  void _openMatchDetail(Match match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PadelMatchDetailScreen(match: match),
      ),
    );
  }

  // Helper Methods
  String _formatJoinDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatMatchDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return _formatJoinDate(date);
    }
  }

  String _formatAchievementDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = difference ~/ 7;
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return _formatJoinDate(date);
    }
  }
}

// Edit Bio Dialog
class PadelEditBioDialog extends StatefulWidget {
  final String currentBio;
  final Function(String) onSave;

  const PadelEditBioDialog({
    super.key,
    required this.currentBio,
    required this.onSave,
  });

  @override
  State<PadelEditBioDialog> createState() => _PadelEditBioDialogState();
}

class _PadelEditBioDialogState extends State<PadelEditBioDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PadelSpacing.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Bio',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Tell us about yourself...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PadelSpacing.sm),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(PadelSpacing.sm),
                  borderSide: BorderSide(color: PadelColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: PadelButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    style: PadelButtonStyle.outline,
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: PadelButton(
                    text: 'Save',
                    onPressed: () {
                      widget.onSave(_controller.text);
                      Navigator.pop(context);
                    },
                    style: PadelButtonStyle.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens
class PadelEditProfileScreen extends StatelessWidget {
  final UserProfile profile;

  const PadelEditProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Edit Profile Screen - Coming Soon!'),
      ),
    );
  }
}

class PadelSettingsScreen extends StatelessWidget {
  final UserProfile profile;

  const PadelSettingsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Settings Screen - Coming Soon!'),
      ),
    );
  }
}