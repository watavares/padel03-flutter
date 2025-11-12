import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.round),
              ),
              child: const Icon(
                Icons.sports_tennis,
                size: 60,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            // App name
            const Text(
              'PadelConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Find players, book courts, play padel',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
            
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}