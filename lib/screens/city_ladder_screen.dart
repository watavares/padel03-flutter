import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';
import '../design_system/components.dart';
import '../services/analytics_service.dart';

// Ladder Models
class LadderPlayer {
  final String id;
  final String name;
  final String? avatarUrl;
  final int rank;
  final int previousRank;
  final int elo;
  final int eloChange;
  final int totalMatches;
  final int wins;
  final int losses;
  final DateTime lastActiveDate;
  final String city;
  final bool isRising;
  final bool isOnFire; // Win streak

  LadderPlayer({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.rank,
    required this.previousRank,
    required this.elo,
    required this.eloChange,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.lastActiveDate,
    required this.city,
    required this.isRising,
    required this.isOnFire,
  });

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;
  int get rankChange => previousRank - rank; // Positive = climbing
}

class CityLadder {
  final String cityName;
  final List<LadderPlayer> players;
  final DateTime lastUpdated;

  CityLadder({
    required this.cityName,
    required this.players,
    required this.lastUpdated,
  });
}

enum LadderFilter { all, rising, falling, active, newPlayers }
enum LadderSort { rank, elo, winRate, activity }

class PadelCityLadderScreen extends StatefulWidget {
  const PadelCityLadderScreen({super.key});

  @override
  State<PadelCityLadderScreen> createState() => _PadelCityLadderScreenState();
}

class _PadelCityLadderScreenState extends State<PadelCityLadderScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  CityLadder? _currentLadder;
  List<LadderPlayer> _filteredPlayers = [];
  bool _isLoading = true;
  LadderFilter _selectedFilter = LadderFilter.all;
  LadderSort _selectedSort = LadderSort.rank;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadLadder();
    
    AnalyticsService.logEvent(
      name: 'city_ladder_viewed',
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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLadder() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      _currentLadder = _generateSampleLadder();
      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading ladder: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  CityLadder _generateSampleLadder() {
    final players = List.generate(50, (index) {
      final rank = index + 1;
      final previousRank = rank + (index % 3 == 0 ? -1 : (index % 3 == 1 ? 1 : 0));
      final isRising = rank < previousRank;
      final elo = 1500 - (rank * 10) + (index % 5 * 20);
      
      return LadderPlayer(
        id: 'player_$index',
        name: _generatePlayerName(index),
        rank: rank,
        previousRank: previousRank,
        elo: elo,
        eloChange: isRising ? 15 : -8,
        totalMatches: 15 + (index % 10),
        wins: 8 + (index % 6),
        losses: 7 + (index % 4),
        lastActiveDate: DateTime.now().subtract(Duration(days: index % 7)),
        city: 'Madrid',
        isRising: isRising,
        isOnFire: index % 7 == 0, // Every 7th player is on fire
      );
    });

    return CityLadder(
      cityName: 'Madrid',
      players: players,
      lastUpdated: DateTime.now(),
    );
  }

  String _generatePlayerName(int index) {
    final names = [
      'Alex Rodriguez', 'Maria Garcia', 'Carlos Silva', 'Ana Martinez',
      'Juan Lopez', 'Sofia Chen', 'David Wilson', 'Emma Taylor',
      'Luis Fernandez', 'Nina Patel', 'Roberto Kim', 'Laura Brown',
      'Pedro Santos', 'Sara White', 'Miguel Torres', 'Elena Ruiz',
      'Diego Morales', 'Claudia Vega', 'Antonio Ramos', 'Isabel Castro',
      'Fernando Jimenez', 'Valeria Herrera', 'Javier Mendez', 'Lucia Gutierrez',
      'Adrian Vargas', 'Carmen Delgado', 'Pablo Ortega', 'Beatriz Romero',
      'Daniel Aguilar', 'Gabriela Flores', 'Sergio Campos', 'Adriana Reyes',
      'Manuel Soto', 'Rocio Navarro', 'Francisco Cruz', 'Alejandra Paredes',
      'Rafael Guerrero', 'Monica Salinas', 'Eduardo Peña', 'Diana Ibarra',
      'Andres Moreno', 'Paola Estrada', 'Hugo Sandoval', 'Cristina Rios',
      'Raul Contreras', 'Lorena Maldonado', 'Mauricio Espinoza', 'Natalia Vera',
      'Guillermo Luna', 'Andrea Fuentes'
    ];
    return names[index % names.length];
  }

  void _applyFiltersAndSort() {
    if (_currentLadder == null) return;

    var filtered = List<LadderPlayer>.from(_currentLadder!.players);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((player) =>
        player.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    switch (_selectedFilter) {
      case LadderFilter.rising:
        filtered = filtered.where((p) => p.isRising).toList();
        break;
      case LadderFilter.falling:
        filtered = filtered.where((p) => !p.isRising && p.rankChange < 0).toList();
        break;
      case LadderFilter.active:
        filtered = filtered.where((p) => 
          p.lastActiveDate.isAfter(DateTime.now().subtract(const Duration(days: 7)))
        ).toList();
        break;
      case LadderFilter.newPlayers:
        filtered = filtered.where((p) => p.totalMatches < 10).toList();
        break;
      case LadderFilter.all:
        // No additional filtering
        break;
    }

    // Apply sorting
    switch (_selectedSort) {
      case LadderSort.rank:
        filtered.sort((a, b) => a.rank.compareTo(b.rank));
        break;
      case LadderSort.elo:
        filtered.sort((a, b) => b.elo.compareTo(a.elo));
        break;
      case LadderSort.winRate:
        filtered.sort((a, b) => b.winRate.compareTo(a.winRate));
        break;
      case LadderSort.activity:
        filtered.sort((a, b) => b.lastActiveDate.compareTo(a.lastActiveDate));
        break;
    }

    setState(() {
      _filteredPlayers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
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
          'City Ladder',
          style: PadelTypography.h5.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
        bottom: _buildTabBar(),
      ),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Rankings'),
        Tab(text: 'Stats'),
        Tab(text: 'Tournaments'),
      ],
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      labelStyle: PadelTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildSearchAndFilters(),
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        children: [
          // Search bar
          PadelTextField(
            placeholder: 'Search players...',
            value: _searchQuery,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _applyFiltersAndSort();
            },
            prefixIcon: Icons.search,
          ),
          
          const SizedBox(height: PadelSpacing.md),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', LadderFilter.all),
                const SizedBox(width: PadelSpacing.sm),
                _buildFilterChip('Rising ↗', LadderFilter.rising),
                const SizedBox(width: PadelSpacing.sm),
                _buildFilterChip('Falling ↘', LadderFilter.falling),
                const SizedBox(width: PadelSpacing.sm),
                _buildFilterChip('Active', LadderFilter.active),
                const SizedBox(width: PadelSpacing.sm),
                _buildFilterChip('New', LadderFilter.newPlayers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, LadderFilter filter) {
    final isSelected = _selectedFilter == filter;
    
    return PadelChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        _applyFiltersAndSort();
        
        AnalyticsService.logEvent(
          name: 'ladder_filter_applied',
          parameters: {'filter': filter.name},
        );
      },
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRankingsTab(),
        _buildStatsTab(),
        _buildTournamentsTab(),
      ],
    );
  }

  Widget _buildRankingsTab() {
    if (_filteredPlayers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadLadder,
      color: PadelColors.primary,
      child: Column(
        children: [
          _buildLadderHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(PadelSpacing.md),
              itemCount: _filteredPlayers.length,
              itemBuilder: (context, index) {
                final player = _filteredPlayers[index];
                return _buildPlayerCard(player, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLadderHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Row(
        children: [
          Icon(Icons.location_on, color: PadelColors.primary, size: 20),
          const SizedBox(width: PadelSpacing.sm),
          Text(
            'Madrid Ladder',
            style: PadelTypography.h6.copyWith(
              fontWeight: FontWeight.bold,
              color: PadelColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            'Updated ${_formatLastUpdated(_currentLadder!.lastUpdated)}',
            style: PadelTypography.caption.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(LadderPlayer player, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: PadelSpacing.md),
        child: PadelCard(
          onTap: () => _showPlayerDetails(player),
          child: Padding(
            padding: const EdgeInsets.all(PadelSpacing.md),
            child: Row(
              children: [
                _buildRankBadge(player),
                const SizedBox(width: PadelSpacing.md),
                _buildPlayerAvatar(player),
                const SizedBox(width: PadelSpacing.md),
                Expanded(child: _buildPlayerInfo(player)),
                _buildPlayerStats(player),
                const SizedBox(width: PadelSpacing.sm),
                _buildRankChange(player),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(LadderPlayer player) {
    Color badgeColor;
    IconData? icon;
    
    if (player.rank <= 3) {
      switch (player.rank) {
        case 1:
          badgeColor = PadelColors.accent; // Gold
          icon = Icons.emoji_events;
          break;
        case 2:
          badgeColor = PadelColors.secondary; // Silver
          icon = Icons.military_tech;
          break;
        case 3:
          badgeColor = PadelColors.primary; // Bronze
          icon = Icons.workspace_premium;
          break;
        default:
          badgeColor = PadelColors.grey400;
      }
    } else {
      badgeColor = PadelColors.grey400;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
        border: Border.all(
          color: badgeColor,
          width: player.rank <= 3 ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '#${player.rank}',
              style: PadelTypography.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: badgeColor,
                fontSize: player.rank >= 100 ? 10 : 12,
              ),
            ),
          ),
          if (icon != null)
            Positioned(
              top: 2,
              right: 2,
              child: Icon(icon, color: badgeColor, size: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(LadderPlayer player) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: PadelColors.primary.withOpacity(0.1),
          backgroundImage: player.avatarUrl != null
              ? NetworkImage(player.avatarUrl!)
              : null,
          child: player.avatarUrl == null
              ? Icon(Icons.person, color: PadelColors.primary, size: 25)
              : null,
        ),
        if (player.isOnFire)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: PadelColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerInfo(LadderPlayer player) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player.name,
          style: PadelTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PadelSpacing.xs),
        Text(
          'Elo: ${player.elo}',
          style: PadelTypography.caption.copyWith(
            color: PadelColors.textSecondary,
          ),
        ),
        const SizedBox(height: PadelSpacing.xs),
        Row(
          children: [
            Text(
              'Win Rate: ${player.winRate.toStringAsFixed(1)}%',
              style: PadelTypography.caption.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            const SizedBox(width: PadelSpacing.sm),
            if (player.isOnFire)
              PadelBadge(
                text: 'Hot',
                style: PadelBadgeStyle.error,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerStats(LadderPlayer player) {
    return Column(
      children: [
        Text(
          '${player.wins}W',
          style: PadelTypography.labelMedium.copyWith(
            color: PadelColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${player.losses}L',
          style: PadelTypography.labelMedium.copyWith(
            color: PadelColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRankChange(LadderPlayer player) {
    final rankChange = player.rankChange;
    
    if (rankChange == 0) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: PadelColors.grey200,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.remove,
          color: PadelColors.textSecondary,
          size: 16,
        ),
      );
    }

    final isRising = rankChange > 0;
    final color = isRising ? PadelColors.success : PadelColors.error;
    final icon = isRising ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 64,
            color: PadelColors.textSecondary,
          ),
          const SizedBox(height: PadelSpacing.md),
          Text(
            'No players found',
            style: PadelTypography.h6.copyWith(
              color: PadelColors.textSecondary,
            ),
          ),
          const SizedBox(height: PadelSpacing.sm),
          Text(
            'Try adjusting your filters',
            style: PadelTypography.bodyMedium.copyWith(
              color: PadelColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        children: [
          _buildOverallStats(),
          const SizedBox(height: PadelSpacing.lg),
          _buildTrendingPlayers(),
          const SizedBox(height: PadelSpacing.lg),
          _buildActivityChart(),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Madrid Ladder Stats',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total Players', '${_currentLadder?.players.length ?? 0}', Icons.people),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: _buildStatCard('Active This Week', '${_getActivePlayersCount()}', Icons.trending_up),
                ),
              ],
            ),
            const SizedBox(height: PadelSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Avg Elo', '${_getAverageElo()}', Icons.bar_chart),
                ),
                const SizedBox(width: PadelSpacing.md),
                Expanded(
                  child: _buildStatCard('Rising Players', '${_getRisingPlayersCount()}', Icons.arrow_upward),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(PadelSpacing.md),
      decoration: BoxDecoration(
        color: PadelColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PadelSpacing.sm),
        border: Border.all(color: PadelColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: PadelColors.primary, size: 24),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingPlayers() {
    final risingPlayers = _currentLadder?.players
        .where((p) => p.isRising)
        .take(5)
        .toList() ?? [];

    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Players',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            ...risingPlayers.map((player) => _buildTrendingPlayerTile(player)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingPlayerTile(LadderPlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: PadelSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: PadelColors.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: PadelColors.primary, size: 16),
          ),
          const SizedBox(width: PadelSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: PadelTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Rank #${player.rank} • +${player.rankChange} positions',
                  style: PadelTypography.caption.copyWith(
                    color: PadelColors.success,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up, color: PadelColors.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ladder Activity',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: PadelColors.grey100,
                borderRadius: BorderRadius.circular(PadelSpacing.sm),
              ),
              child: Center(
                child: Text(
                  'Activity Chart Coming Soon',
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PadelSpacing.md),
      child: Column(
        children: [
          _buildUpcomingTournaments(),
          const SizedBox(height: PadelSpacing.lg),
          _buildRecentTournaments(),
        ],
      ),
    );
  }

  Widget _buildUpcomingTournaments() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Tournaments',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Container(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              decoration: BoxDecoration(
                color: PadelColors.grey100,
                borderRadius: BorderRadius.circular(PadelSpacing.sm),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: PadelColors.textSecondary,
                    ),
                    const SizedBox(height: PadelSpacing.md),
                    Text(
                      'No upcoming tournaments',
                      style: PadelTypography.bodyMedium.copyWith(
                        color: PadelColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: PadelSpacing.sm),
                    PadelButton(
                      text: 'Create Tournament',
                      onPressed: _createTournament,
                      style: PadelButtonStyle.primary,
                      size: PadelButtonSize.small,
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

  Widget _buildRecentTournaments() {
    return PadelCard(
      child: Padding(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Tournaments',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.md),
            Text(
              'Tournament history will appear here',
              style: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Methods
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(PadelSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PadelSpacing.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter & Sort',
              style: PadelTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                color: PadelColors.primary,
              ),
            ),
            const SizedBox(height: PadelSpacing.lg),
            Text('Advanced filters coming soon!'),
            const SizedBox(height: PadelSpacing.lg),
            PadelButton(
              text: 'Close',
              onPressed: () => Navigator.pop(context),
              style: PadelButtonStyle.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSearch() {
    // Toggle search functionality
  }

  void _showPlayerDetails(LadderPlayer player) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PadelPlayerDetailScreen(player: player),
      ),
    );

    AnalyticsService.logEvent(
      name: 'ladder_player_viewed',
      parameters: {
        'player_id': player.id,
        'player_rank': player.rank,
      },
    );
  }

  void _createTournament() {
    AnalyticsService.logEvent(name: 'tournament_create_tapped');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tournament creation coming soon!')),
    );
  }

  // Helper Methods
  int _getActivePlayersCount() {
    return _currentLadder?.players
        .where((p) => p.lastActiveDate.isAfter(
          DateTime.now().subtract(const Duration(days: 7))))
        .length ?? 0;
  }

  int _getAverageElo() {
    if (_currentLadder?.players.isEmpty ?? true) return 0;
    final totalElo = _currentLadder!.players.fold<int>(0, (sum, p) => sum + p.elo);
    return (totalElo / _currentLadder!.players.length).round();
  }

  int _getRisingPlayersCount() {
    return _currentLadder?.players.where((p) => p.isRising).length ?? 0;
  }

  String _formatLastUpdated(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Player Detail Screen
class PadelPlayerDetailScreen extends StatelessWidget {
  final LadderPlayer player;

  const PadelPlayerDetailScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        backgroundColor: PadelColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Player Detail Screen - Coming Soon!'),
      ),
    );
  }
}