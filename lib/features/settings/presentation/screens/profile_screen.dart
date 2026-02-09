import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';
import 'package:film_cam/features/settings/presentation/screens/settings_screen.dart';
import 'package:film_cam/features/settings/presentation/screens/development_history_screen.dart';
import 'package:film_cam/features/auth/providers/auth_provider.dart';
import '../../../../features/onboarding/presentation/screens/onboarding_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(dynamicUserStatsProvider);
    final tc = context.colors;

    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
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
                color: tc.accentSubtle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 48),
                  statsAsync.when(
                    data: (stats) => _buildStatsRow(context, stats),
                    loading: () => Center(child: CircularProgressIndicator(color: tc.accent)),
                    error: (_, __) => _buildStatsRow(context, UserStats(captures: 0, rolls: 0, likes: 0)),
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
              child: AdaptiveGlass(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
                borderColor: Colors.transparent,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.iconPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile user) {
    final tc = context.colors;
    return Column(
      children: [
        FadeInDown(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: tc.accent, width: 2),
              boxShadow: [
                BoxShadow(color: tc.accent.withOpacity(0.2), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 48,
                  color: tc.accent,
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
              color: tc.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeIn(
          delay: const Duration(milliseconds: 500),
          child: Text(
            '${user.membershipStatus} • EST ${user.joinedDate.year}',
            style: AppTypography.monoSmall.copyWith(
              color: tc.accentSecondary,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, UserStats stats) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(context, stats.captures.toString(), 'CAPTURES'),
          _statDivider(context),
          _statItem(context, stats.rolls.toString(), 'ROLLS'),
          _statDivider(context),
          _statItem(context, stats.likes.toString(), 'LIKES'),
        ],
      ),
    );
  }

  Widget _statItem(BuildContext context, String value, String label) {
    final tc = context.colors;
    return Column(
      children: [
        Text(value, style: AppTypography.displaySmall.copyWith(color: tc.accent, fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.labelMedium.copyWith(color: tc.textMuted, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _statDivider(BuildContext context) {
    return Container(width: 1, height: 30, color: context.colors.borderSubtle);
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, UserProfile user) {
    final tc = context.colors;
    return Column(
      children: [
        _menuTile(
          context: context,
          icon: Icons.settings_outlined,
          title: 'PREFERENCES',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        _menuTile(
          context: context,
          icon: Icons.history_rounded,
          title: 'DEVELOPMENT HISTORY',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevelopmentHistoryScreen())),
        ),
        if (!user.isPro)
          _menuTile(
            context: context,
            icon: Icons.workspace_premium_outlined,
            title: 'UPGRADE TO PRO',
            onTap: () {
              ref.read(userProfileProvider.notifier).upgradeToPro();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Welcome to the Royal Club!'), backgroundColor: tc.proBadgeBackground),
              );
            },
            isGold: true,
          ),
        _menuTile(
          context: context,
          icon: Icons.logout_rounded,
          title: 'SIGN OUT',
          onTap: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) {
              // Navigate to onboarding so user can redo setup or skip to login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen(showSkipToLogin: true)),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isGold = false,
  }) {
    final tc = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AdaptiveGlass(
        height: 64,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isGold ? tc.proBadgeBackground : tc.iconSecondary),
          title: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: isGold ? tc.proBadgeBackground : tc.textPrimary,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          trailing: Icon(Icons.chevron_right_rounded, color: tc.textFaint),
          onTap: onTap,
        ),
      ),
    );
  }
}
