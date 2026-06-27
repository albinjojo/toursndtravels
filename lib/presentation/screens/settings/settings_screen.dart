import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/school_providers.dart';
import '../../../providers/student_providers.dart';
import '../../../routing/app_router.dart';
import '../../widgets/common/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final school = ref.watch(selectedSchoolProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    school?.name ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  SettingsTile(
                    iconData: Icons.school_rounded,
                    iconBg: AppColors.navActiveBg,
                    iconColor: AppColors.primary,
                    title: 'Switch School',
                    subtitle: 'Currently: ${school?.name ?? '—'}',
                    onTap: () {
                      ref.read(selectedSchoolProvider.notifier).state = null;
                      ref.read(studentFiltersProvider.notifier).clearAll();
                      context.go(AppRoutes.schools);
                    },
                  ),
                  const SizedBox(height: 10),
                  SettingsTile(
                    iconData: Icons.cloud_upload_rounded,
                    iconBg: AppColors.successBg,
                    iconColor: AppColors.success,
                    title: 'Backup to Firebase',
                    subtitle: 'Last backup: Never',
                    onTap: () => _showComingSoon(context, 'Backup'),
                  ),
                  const SizedBox(height: 10),
                  SettingsTile(
                    iconData: Icons.cloud_download_rounded,
                    iconBg: AppColors.secondTripBg,
                    iconColor: AppColors.secondTripText,
                    title: 'Restore Backup',
                    subtitle: 'Download from Firebase',
                    onTap: () => _showComingSoon(context, 'Restore'),
                  ),
                  const SizedBox(height: 10),
                  SettingsTile(
                    iconData: Icons.info_outline_rounded,
                    iconBg: AppColors.warningBg,
                    iconColor: AppColors.warning,
                    title: 'About',
                    subtitle: 'Alphonsa Van Service v2.0.0',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Alphonsa Van Service',
      applicationVersion: 'v2.0.0',
      applicationLegalese: '© 2025 Alphonsa Van Service',
      children: [
        const SizedBox(height: 8),
        const Text('Student transport management for school van operators.'),
      ],
    );
  }
}
