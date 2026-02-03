import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';
import 'package:film_cam/features/settings/presentation/screens/settings_screen.dart';
import 'package:film_cam/features/settings/presentation/screens/development_history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Elegant Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGold.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildProfileHeader(user),
                  const SizedBox(height: 48),
                  statsAsync.when(
                    data: (stats) => _buildStatsRow(stats),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
                    error: (_, __) => _buildStatsRow(UserStats(captures: 0, rolls: 0, likes: 0)),
                  ),
                  const SizedBox(height: 48),
                  _buildMenuSection(context, ref, user),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GlassContainer.clearGlass(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
                borderColor: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Column(
      children: [
        FadeInDown(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGold, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.accentGold.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0] : '?',
                style: const TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 48,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeIn(
          delay: const Duration(milliseconds: 300),
          child: Text(
            user.name.toUpperCase(),
            style: AppTypography.displayMedium.copyWith(
              fontSize: 24,
              letterSpacing: 4,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeIn(
          delay: const Duration(milliseconds: 500),
          child: Text(
            '${user.membershipStatus} • EST ${user.joinedDate.year}',
            style: AppTypography.monoSmall.copyWith(
              color: AppColors.accentGold.withOpacity(0.6),
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserStats stats) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(stats.captures.toString(), 'CAPTURES'),
          _statDivider(),
          _statItem(stats.rolls.toString(), 'ROLLS'),
          _statDivider(),
          _statItem(stats.likes.toString(), 'LIKES'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.displaySmall.copyWith(color: AppColors.accentGold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelMedium.copyWith(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 30, color: Colors.white10);
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, UserProfile user) {
    return Column(
      children: [
        _menuTile(
          icon: Icons.settings_outlined,
          title: 'PREFERENCES',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        _menuTile(
          icon: Icons.history_rounded,
          title: 'DEVELOPMENT HISTORY',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevelopmentHistoryScreen())),
        ),
        if (!user.isPro)
          _menuTile(
            icon: Icons.workspace_premium_outlined,
            title: 'UPGRADE TO PRO',
            onTap: () {
              ref.read(userProfileProvider.notifier).upgradeToPro();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Welcome to the Royal Club!'), backgroundColor: AppColors.accentGold),
              );
            },
            isGold: true,
          ),
        _menuTile(
          icon: Icons.logout_rounded,
          title: 'SIGN OUT',
          onTap: () {
            ref.read(userProfileProvider.notifier).signOut();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isGold = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer.clearGlass(
        height: 64,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isGold ? AppColors.accentGold : Colors.white70),
          title: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: isGold ? AppColors.accentGold : Colors.white,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          onTap: onTap,
        ),
      ),
    );
  }
}
