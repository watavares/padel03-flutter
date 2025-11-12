import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../providers/analytics_providers.dart';
import '../routing/app_router.dart';
import '../models/user_model.dart';

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsControllerProvider).trackScreenView('main_app');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final navigation = ref.watch(navigationProvider);
    
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'PadelConnect',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                user?.displayNameOrEmail.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'signout',
                child: Text('Sign Out'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  // TODO: Navigate to profile
                  break;
                case 'settings':
                  // TODO: Navigate to settings
                  break;
                case 'signout':
                  ref.read(authControllerProvider.notifier).signOut();
                  break;
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              'Welcome back, ${user?.displayNameOrEmail ?? 'Player'}!',
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Quick stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Skill Level',
                    value: user?.skill.effectiveLevel?.displayName ?? 'Not Set',
                    icon: Icons.star,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildStatCard(
                    title: 'Games Played',
                    value: '0', // TODO: Add games count
                    icon: Icons.sports_tennis,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            // Quick actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Find Games',
                    subtitle: 'Join existing lobbies',
                    icon: Icons.groups,
                    onTap: () {
                      ref.read(analyticsControllerProvider).trackButtonPress('find_games', 'main_app');
                      navigation.goToLobbies();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildActionCard(
                    title: 'Book Courts',
                    subtitle: 'Reserve a court',
                    icon: Icons.calendar_today,
                    onTap: () {
                      ref.read(analyticsControllerProvider).trackButtonPress('book_courts', 'main_app');
                      // TODO: Navigate to court booking
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: 'Find Courts',
                    subtitle: 'Discover nearby courts',
                    icon: Icons.location_on,
                    onTap: () {
                      // TODO: Navigate to court discovery
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _buildActionCard(
                    title: 'My Profile',
                    subtitle: 'Update your info',
                    icon: Icons.person,
                    onTap: () {
                      // TODO: Navigate to profile
                    },
                  ),
                ),
              ],
            ),
            
            const Spacer(),
            
            // Recent activity placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.small,
              ),
              child: Column(
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No recent activity yet.\nStart playing to see your game history here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}