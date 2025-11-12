import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
import '../providers/auth_providers.dart';
import '../pages/modern_login_page.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../design_system/modern_components.dart';
import '../screens/availability_editor.dart';
import '../screens/browse_lobbies_screen.dart' as new_screens;
import '../screens/lobby_detail_screen.dart';
import '../screens/enhanced_profile_screen.dart';
import '../screens/city_ladder_screen.dart';
import '../screens/log_match_screen.dart';
import '../screens/create_lobby_screen.dart';
import '../providers/lobby_providers.dart';
import '../models/lobby_model.dart';
import '../models/user_model.dart';

class PadelArenaApp extends ConsumerStatefulWidget {
  const PadelArenaApp({super.key});

  @override
  ConsumerState<PadelArenaApp> createState() => _PadelArenaAppState();
}

class _PadelArenaAppState extends ConsumerState<PadelArenaApp> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    PadelHomeScreen(onNavigateToTab: _navigateToTab),
    const new_screens.BrowseLobbiesScreen(),
    const PadelCityLadderScreen(),
    const PadelEnhancedProfileScreen(),
  ];

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12), // More padding
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Theme.of(context).colorScheme.primary, // Use theme primary
              unselectedItemColor: Colors.grey.shade600, // Darker grey when not selected
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), // Rounded home icon
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded), // Calendar icon for lobbies
                  label: 'Lobbies',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_rounded), // Rounded trophy/ladder icon
                  label: 'Ladder',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded), // Rounded profile icon
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Original Home Screen (v1) - Preserved for fallback
class PadelHomeScreenV1 extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const PadelHomeScreenV1({super.key, this.onNavigateToTab});

  @override
  State<PadelHomeScreenV1> createState() => _PadelHomeScreenV1State();
}

// New Enhanced Home Screen (v2)
class PadelHomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const PadelHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<PadelHomeScreen> createState() => _PadelHomeScreenState();
}

class _PadelHomeScreenV1State extends State<PadelHomeScreenV1>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isDisposed = false;
  bool _isAvailable = false;
  int _currentRank = 15;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startEntryAnimation();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: PadelAnimations.slow,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: PadelAnimations.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: PadelAnimations.smoothOut,
    ));
  }

  void _startEntryAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted && !_isDisposed) {
      _fadeController.forward();
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted && !_isDisposed) {
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(),
                  _buildPlayerStats(),
                  _buildAvailabilityToggle(),
                  _buildFreeLobbies(),
                  _buildQuickActions(),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: PadelSpacing.xl),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          children: [
            // Phase 1: Hero section with rank/XP prominence
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: PadelSpacing.xs),
                      Consumer(
                        builder: (context, ref, child) {
                          final userAsync = ref.watch(currentUserProvider);
                          return userAsync.when(
                            data: (user) => Text(
                              user?.displayNameOrEmail ?? 'Padel Player',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            loading: () => Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            error: (_, __) => Text(
                              'Padel Player',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Enhanced rank badge - more prominent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#$_currentRank',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: PadelSpacing.lg),
            
            // Phase 1: Primary CTAs - Find Match and Create Lobby buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.onNavigateToTab!(2), // Navigate to Find Matches
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                    ),
                    icon: Icon(Icons.calendar_month_rounded, size: 20, color: Colors.grey.shade700), 
                    label: Text('Find Match', style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    )),
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateLobbyScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                    label: const Text('Create Lobby', style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
        child: PadelModernCard(
          child: Column(
            children: [
              // Simplified stats without XP
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      title: 'Matches Today',
                      value: '2',
                      icon: Icons.sports_tennis,
                      color: PadelColors.secondary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: PadelColors.grey200,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      title: 'Win Streak',
                      value: '5',
                      icon: Icons.local_fire_department,
                      color: PadelColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: PadelSpacing.sm),
        Text(
          value,
          style: PadelTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: PadelColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: PadelTypography.caption.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: PadelModernCard(
          child: PadelModernToggle(
            value: _isAvailable,
            onChanged: (value) {
              setState(() {
                _isAvailable = value;
              });
              // Simple feedback when becoming available
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You're now available to play!"),
                    backgroundColor: PadelColors.accent,
                  ),
                );
              }
            },
            label: "I'm Available to Play",
            subtitle: _isAvailable 
              ? "You'll receive match invitations"
              : "Turn on to find opponents",
          ),
        ),
      ),
    );
  }

  Widget _buildFreeLobbies() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Free Lobbies to Join',
                  style: PadelTypography.h6.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateToTab?.call(2), // Browse Lobbies
                  child: Text(
                    'View All',
                    style: PadelTypography.labelMedium.copyWith(
                      color: PadelColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          SizedBox(
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final lobbiesAsync = ref.watch(openLobbiesProvider);
                
                return lobbiesAsync.when(
                  data: (lobbies) {
                    if (lobbies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 48,
                              color: PadelColors.textSecondary,
                            ),
                            const SizedBox(height: PadelSpacing.sm),
                            Text(
                              'No lobbies available',
                              style: PadelTypography.bodyMedium.copyWith(
                                color: PadelColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: PadelSpacing.xs),
                            Text(
                              'Be the first to create one!',
                              style: PadelTypography.caption.copyWith(
                                color: PadelColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: PadelSpacing.lg),
                      itemCount: lobbies.length,
                      itemBuilder: (context, index) {
                        final lobby = lobbies[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < lobbies.length - 1 ? PadelSpacing.md : 0,
                          ),
                          child: _buildLobbyCard(lobby),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: PadelColors.primary,
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: PadelColors.error,
                        ),
                        const SizedBox(height: PadelSpacing.sm),
                        Text(
                          'Failed to load lobbies',
                          style: PadelTypography.bodyMedium.copyWith(
                            color: PadelColors.error,
                          ),
                        ),
                        const SizedBox(height: PadelSpacing.xs),
                        Text(
                          error.toString(),
                          style: PadelTypography.caption.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyCard(LobbyModel lobby) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyDetailScreen(
              lobbyId: lobby.id,
            ),
          ),
        );
      },
      child: PadelModernCard(
        backgroundColor: Colors.white.withOpacity(0.95),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 280,
          ),
          child: IntrinsicHeight(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              // Title and Level Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      lobby.title,
                      style: PadelTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PadelSpacing.sm,
                      vertical: PadelSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: PadelColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      lobby.skillLevel.displayName,
                      style: PadelTypography.caption.copyWith(
                        color: PadelColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PadelSpacing.xs),
              // Host info
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: PadelColors.grey200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: PadelColors.textSecondary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: PadelSpacing.sm),
                  Text(
                    lobby.organizerName,
                    style: PadelTypography.caption.copyWith(
                      color: PadelColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PadelSpacing.sm),
              // Time and location
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: PadelColors.textSecondary,
                  ),
                  const SizedBox(width: PadelSpacing.xs),
                  Text(
                    lobby.formattedDateTime,
                    style: PadelTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: PadelSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.sports_tennis,
                    size: 16,
                    color: PadelColors.textSecondary,
                  ),
                  const SizedBox(width: PadelSpacing.xs),
                  Expanded(
                    child: Text(
                      '${lobby.clubName} - ${lobby.courtName}',
                      style: PadelTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PadelSpacing.xs),
              // Players and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group,
                        color: PadelColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: PadelSpacing.xs),
                      Text(
                        '${lobby.availableSpots} spots left',
                        style: PadelTypography.caption.copyWith(
                          color: PadelColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (lobby.pricePerPlayer > 0)
                    Text(
                      '€${lobby.pricePerPlayer.toStringAsFixed(0)}',
                      style: PadelTypography.bodyMedium.copyWith(
                        color: PadelColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: PadelTypography.h6.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Find Match',
                    subtitle: 'Browse lobbies',
                    icon: Icons.search,
                    onTap: () => widget.onNavigateToTab?.call(2),
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: _buildActionCard(
                    title: 'City Ladder',
                    subtitle: 'View rankings',
                    icon: Icons.leaderboard,
                    onTap: () => widget.onNavigateToTab?.call(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Log Match',
                    subtitle: 'Record results',
                    icon: Icons.edit_note,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogMatchScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: _buildActionCard(
                    title: 'Availability',
                    subtitle: 'Set schedule',
                    icon: Icons.schedule,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PadelAvailabilityEditor(),
                        ),
                      );
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

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return PadelModernCard(
      onTap: onTap,
      backgroundColor: Colors.white.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: PadelColors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PadelColors.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            title,
            style: PadelTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: PadelTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class PadelLeaderboardScreen extends StatelessWidget {
  const PadelLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.background,
      appBar: AppBar(
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'City Ladder',
          style: PadelTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: PadelColors.accent),
            SizedBox(height: PadelSpacing.md),
            Text(
              'City Ladder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: PadelSpacing.sm),
            Text('Ranking system coming soon'),
          ],
        ),
      ),
    );
  }
}

class PadelProfileScreen extends StatelessWidget {
  const PadelProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      await AnalyticsService.logEvent(
        name: 'user_signed_out',
        parameters: {'source': 'profile_screen'},
      );
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ModernLoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PadelColors.background,
      appBar: AppBar(
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: PadelTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PadelSpacing.md),
        child: Column(
          children: [
            PadelCard(
              child: Padding(
                padding: const EdgeInsets.all(PadelSpacing.lg),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: PadelColors.primary,
                      child: StreamBuilder(
                        stream: AuthService.authStateChanges,
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          if (user?.photoURL != null) {
                            return ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            );
                          }
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    StreamBuilder(
                      stream: AuthService.authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return Column(
                          children: [
                            Text(
                              user?.displayName ?? 'Padel Player',
                              style: PadelTypography.h6.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PadelColors.primary,
                              ),
                            ),
                            const SizedBox(height: PadelSpacing.xs),
                            Text(
                              user?.email ?? 'player@padelarena.com',
                              style: PadelTypography.bodyMedium.copyWith(
                                color: PadelColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: PadelSpacing.sm),
                            if (user != null)
                              PadelBadge(
                                text: user.emailVerified ? 'Verified' : 'Unverified',
                                style: user.emailVerified 
                                  ? PadelBadgeStyle.success 
                                  : PadelBadgeStyle.warning,
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: PadelSpacing.lg),
                    
                    // Profile Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Matches', '24'),
                        _buildStatCard('Wins', '18'),
                        _buildStatCard('Rank', '#15'),
                      ],
                    ),
                    const SizedBox(height: PadelSpacing.lg),
                    
                    // XP Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Experience - Level 8',
                          style: PadelTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: PadelColors.primary,
                          ),
                        ),
                        const SizedBox(height: PadelSpacing.sm),
                        const PadelXPProgressBar(
                          currentXP: 750,
                          maxXP: 1000,
                          label: '750/1000 XP',
                        ),
                      ],
                    ),
                    const SizedBox(height: PadelSpacing.lg),
                    
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: PadelButton(
                        text: 'Sign Out',
                        onPressed: () => _signOut(context),
                        style: PadelButtonStyle.secondary,
                        icon: Icons.logout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: PadelTypography.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: PadelColors.primary,
          ),
        ),
        const SizedBox(height: PadelSpacing.xs),
        Text(
          label,
          style: PadelTypography.caption.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// New Enhanced Home Screen (v2) Implementation
class _PadelHomeScreenState extends State<PadelHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light grey background
      body: Column(
        children: [
          _buildFixedTopNavigation(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildHeaderSection(),
                  _buildTopActionButtons(),
                  _buildGameInsightsCard(),
                  _buildSuggestedLobbies(),
                  _buildLadderStatsCard(),
                  _buildQuickActions(),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Extra padding for bottom nav
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedTopNavigation() {
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
              // Left: App logo/wordmark
              GestureDetector(
                onTap: () {
                  // Scroll to top or refresh
                },
                child: Text(
                  'PadelArena',
                  style: PadelTypography.h5.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              
              // Right: Notifications and Settings
              Row(
                children: [
                  // Notifications with badge
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifications coming soon!')),
                          );
                        },
                      ),
                      // Badge for unread notifications
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: PadelColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Settings
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: Colors.grey.shade700,
                      size: 24,
                    ),
                    onPressed: () => widget.onNavigateToTab?.call(3), // Navigate to profile
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Dynamic greeting
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final userAsync = ref.watch(currentUserProvider);
                  return userAsync.when(
                    data: (user) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: PadelTypography.h5.copyWith(
                            color: PadelColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          user?.displayNameOrEmail.split('@')[0] ?? 'Player',
                          style: PadelTypography.h4.copyWith(
                            color: PadelColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: PadelTypography.h5.copyWith(
                            color: PadelColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Player',
                          style: PadelTypography.h4.copyWith(
                            color: PadelColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    error: (_, __) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: PadelTypography.h5.copyWith(
                            color: PadelColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Player',
                          style: PadelTypography.h4.copyWith(
                            color: PadelColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Right: Player level chip with progress
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [PadelColors.accent, PadelColors.accent.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: PadelColors.accent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '3.57',
                        style: PadelTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Progress bar to next level
                Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.57, // 57% progress to next level
                    child: Container(
                      decoration: BoxDecoration(
                        color: PadelColors.primary, // Dark blue progression bar
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopActionButtons() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Find Match button
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton.icon(
                  onPressed: () => widget.onNavigateToTab?.call(1), // Navigate to lobbies
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PadelColors.accent, // Lime background
                    foregroundColor: PadelColors.primary, // Dark blue text
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return PadelColors.primary.withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                  ),
                  icon: const Icon(Icons.search, size: 20),
                  label: Text(
                    'Find Match',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Create Lobby button
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateLobbyScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PadelColors.primary, // Dark blue text
                    side: BorderSide(color: PadelColors.primary, width: 2), // Blue border
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.pressed)) {
                          return const Color(0xFF35BFD6).withOpacity(0.1); // Light blue on press
                        }
                        return null;
                      },
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    'Create Lobby',
                    style: PadelTypography.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInsightsCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.grey.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Win Rate with circular progress
                  Expanded(
                    child: _buildInsightStat(
                      title: 'Win Rate',
                      value: '68%',
                      icon: Icons.gps_fixed,
                      progress: 0.68,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Matches Played
                  Expanded(
                    child: _buildInsightStat(
                      title: 'Matches Played',
                      value: '24',
                      icon: Icons.sports_tennis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightStat({
    required String title,
    required String value,
    required IconData icon,
    double? progress,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (progress != null)
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuggestedLobbies() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested Lobbies Near You',
                  style: PadelTypography.h6.copyWith(
                    color: PadelColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onNavigateToTab?.call(1),
                  child: Text(
                    'View All',
                    style: PadelTypography.labelMedium.copyWith(
                      color: PadelColors.primary, // Dark blue text
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final lobbiesAsync = ref.watch(openLobbiesProvider);
                
                return lobbiesAsync.when(
                  data: (lobbies) {
                    if (lobbies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_tennis,
                              size: 48,
                              color: PadelColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No lobbies near you',
                              style: PadelTypography.bodyMedium.copyWith(
                                color: PadelColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: lobbies.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < lobbies.length - 1 ? 16 : 0,
                          ),
                          child: _buildSuggestedLobbyCard(lobbies[index]),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(color: PadelColors.primary),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Failed to load lobbies',
                      style: PadelTypography.bodyMedium.copyWith(
                        color: PadelColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedLobbyCard(LobbyModel lobby) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyDetailScreen(lobbyId: lobby.id),
          ),
        );
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Time and Open button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lobby.formattedDateTime,
                      style: PadelTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PadelColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: PadelColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lobby.clubName,
                          style: PadelTypography.bodyMedium.copyWith(
                            color: PadelColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lobby.skillLevel.displayName,
                      style: PadelTypography.bodyMedium.copyWith(
                        color: PadelColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: lobby.isJoinable ? PadelColors.accent : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    lobby.isJoinable ? 'Open' : 'Full',
                    style: PadelTypography.labelMedium.copyWith(
                      color: lobby.isJoinable ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Bottom: Player avatars and spots left
            Row(
              children: [
                // Player avatars
                if (lobby.players.isNotEmpty)
                  Row(
                    children: lobby.players.take(3).map((player) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [PadelColors.primary, PadelColors.secondary],
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: player.photoUrl != null && player.photoUrl!.isNotEmpty
                            ? Image.network(
                                player.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                
                const SizedBox(width: 8),
                
                Text(
                  '+${lobby.availableSpots} spots left',
                  style: PadelTypography.bodySmall.copyWith(
                    color: PadelColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLadderStatsCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.grey.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Your City Ranking',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // City and rank info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Valencia Ladder',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildLadderStat('Rank', '#15'),
                            const SizedBox(width: 24),
                            _buildLadderStat('Matches', '42'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // View Ladder button
                  OutlinedButton(
                    onPressed: () => widget.onNavigateToTab?.call(2), // Navigate to ladder
                    child: Text(
                      'View Ladder',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildLadderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: PadelTypography.h6.copyWith(
                color: PadelColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 2x2 Grid of quick actions
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildQuickActionCard(
                  title: 'Find Lobbies',
                  icon: Icons.search,
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
                _buildQuickActionCard(
                  title: 'My Matches',
                  icon: Icons.sports_tennis,
                  onTap: () => widget.onNavigateToTab?.call(1), // Navigate to My Matches tab
                ),
                _buildQuickActionCard(
                  title: 'Calendar',
                  icon: Icons.calendar_month,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calendar coming soon!')),
                    );
                  },
                ),
                _buildQuickActionCard(
                  title: 'Friends',
                  icon: Icons.people_outline,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friends feature coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: PadelColors.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PadelColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: PadelColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D556D),
        foregroundColor: Colors.white,
        title: const Text(
          'PadelArena',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1D556D),
                    const Color(0xFF2A809E),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to PadelArena!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find courts, join matches, and climb the ladder!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D556D),
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  context,
                  'Book Court',
                  Icons.calendar_today,
                  const Color(0xFF2A809E),
                  'Reserve your spot',
                ),
                _buildActionCard(
                  context,
                  'Find Match',
                  Icons.groups,
                  const Color(0xFF1D556D),
                  'Join other players',
                ),
                _buildActionCard(
                  context,
                  'Tournament',
                  Icons.emoji_events,
                  const Color(0xFFD3FF21),
                  'Compete & win',
                ),
                _buildActionCard(
                  context,
                  'My Stats',
                  Icons.analytics,
                  const Color(0xFF2A809E),
                  'Track progress',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1D556D),
              ),
            ),
            const SizedBox(height: 16),

            _buildActivityCard(
              context,
              'Match Completed',
              'You won against Team Alpha 6-4, 6-2',
              '2 hours ago',
              Icons.emoji_events,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildActivityCard(
              context,
              'Court Booked',
              'Court 3 reserved for tomorrow 6:00 PM',
              '1 day ago',
              Icons.calendar_today,
              const Color(0xFF2A809E),
            ),
            const SizedBox(height: 8),
            _buildActivityCard(
              context,
              'Ranking Updated',
              'You moved up to #15 in the ladder!',
              '3 days ago',
              Icons.trending_up,
              const Color(0xFFD3FF21),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, String subtitle, {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon!')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, String title, String description, String time, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D556D),
        foregroundColor: Colors.white,
        title: const Text('Court Availability'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Color(0xFF2A809E)),
            SizedBox(height: 16),
            Text(
              'Court Availability',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Book your favorite court'),
          ],
        ),
      ),
    );
  }
}

class LobbiesScreen extends StatelessWidget {
  const LobbiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D556D),
        foregroundColor: Colors.white,
        title: const Text('Player Lobbies'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Color(0xFF2A809E)),
            SizedBox(height: 16),
            Text(
              'Player Lobbies',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Find and join other players'),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D556D),
        foregroundColor: Colors.white,
        title: const Text('Leaderboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Color(0xFFD3FF21)),
            SizedBox(height: 16),
            Text(
              'Leaderboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Check your ranking'),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await AuthService.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ModernLoginPage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D556D),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1D556D),
                      child: StreamBuilder(
                        stream: AuthService.authStateChanges,
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          if (user?.photoURL != null) {
                            return ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            );
                          }
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                      stream: AuthService.authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return Column(
                          children: [
                            Text(
                              user?.displayName ?? 'Padel Player',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1D556D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'player@padelarena.com',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (user != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: user.emailVerified
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.emailVerified ? 'Verified' : 'Unverified',
                                  style: TextStyle(
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Profile Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Matches', '24'),
                        _buildStatCard('Wins', '18'),
                        _buildStatCard('Rank', '#15'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _signOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1D556D),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}