import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/nav_content.dart';
import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/profile_models.dart';
import 'goal_card.dart';
import 'identity_card.dart';
import 'learning_stats_card.dart';
import 'level_card.dart';
import 'profile_section_sliver.dart';
import 'settings_group.dart';

/// Profil sekmesinin hazır durum görünümü: kimlik kartı, istatistikler,
/// seviye, günlük hedef, ayarlar ve hesap satırları. Satırlar cubit
/// bağlanana kadar pasiftir.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.profile,
    required this.settings,
    required this.stats,
    required this.doneToday,
    this.onEditProfile,
    this.onRetakeLevelTest,
    this.onChangeGoal,
    this.onOpenLanguage,
    this.onOpenNotifications,
    this.onOpenAudio,
    this.onOpenReading,
    this.onOpenChangePassword,
    this.onLogout,
    this.onDeleteAccount,
  });

  final UserProfile profile;
  final ProfileSettings settings;
  final ProfileStats stats;
  final int doneToday;
  final VoidCallback? onEditProfile;
  final VoidCallback? onRetakeLevelTest;
  final VoidCallback? onChangeGoal;
  final VoidCallback? onOpenLanguage;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenAudio;
  final VoidCallback? onOpenReading;
  final VoidCallback? onOpenChangePassword;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;

  String _notificationSummary(NotificationPrefs prefs) {
    final int open = [
      prefs.practiceReminder,
      prefs.streakGuard,
      prefs.newContent,
    ].where((bool value) => value).length;
    return '$open / 3';
  }

  String _audioSummary(AudioPrefs audio) {
    if (!audio.readAloud && !audio.soundEffects) {
      return ProfileContent.offLabel;
    }
    return ProfileContent.speedTemplate.replaceFirst(
      '{speed}',
      audio.speed.toStringAsFixed(2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        NavContent.profileTitle,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.inkDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        ProfileContent.screenSubtitle,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: ProfileIdentityHeaderDelegate(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ProfileIdentityCard(
                        profile: profile,
                        onEdit: onEditProfile,
                      ),
                    ),
                  ),
                ),
              ),
              ProfileSectionSliver(
                label: ProfileContent.statsSectionLabel,
                child: ProfileStatsCard(stats: stats),
              ),
              ProfileSectionSliver(
                label: ProfileContent.levelSectionLabel,
                child: ProfileLevelCard(
                  profile: profile,
                  onRetakeTest: onRetakeLevelTest,
                ),
              ),
              ProfileSectionSliver(
                label: ProfileContent.goalSectionLabel,
                child: ProfileGoalCard(
                  settings: settings,
                  doneToday: doneToday,
                  onChangeGoal: onChangeGoal,
                ),
              ),
              ProfileSectionSliver(
                label: ProfileContent.settingsSectionLabel,
                child: SettingsGroup(
                  children: <Widget>[
                    SettingTile(
                      icon: Iconsax.global,
                      title: ProfileContent.languageRowLabel,
                      value: ProfileContent.languageLabels[settings.language]!,
                      onTap: onOpenLanguage,
                    ),
                    SettingTile(
                      icon: Iconsax.notification_1,
                      title: ProfileContent.notificationsRowLabel,
                      value: _notificationSummary(settings.notifications),
                      onTap: onOpenNotifications,
                    ),
                    SettingTile(
                      icon: Iconsax.volume_high,
                      title: ProfileContent.audioRowLabel,
                      value: _audioSummary(settings.audio),
                      onTap: onOpenAudio,
                    ),
                    SettingTile(
                      icon: Iconsax.note,
                      title: ProfileContent.readingRowLabel,
                      value: ProfileContent
                          .textSizeLabels[settings.reading.textSize]!,
                      onTap: onOpenReading,
                    ),
                  ],
                ),
              ),
              ProfileSectionSliver(
                label: ProfileContent.accountSectionLabel,
                last: true,
                child: SettingsGroup(
                  children: <Widget>[
                    SettingTile(
                      icon: Iconsax.password_check,
                      title: ProfileContent.changePasswordRowLabel,
                      onTap: onOpenChangePassword,
                    ),
                    SettingTile(
                      icon: Iconsax.logout_1,
                      title: ProfileContent.logoutRowLabel,
                      onTap: onLogout,
                    ),
                    SettingTile(
                      icon: Iconsax.shield_cross,
                      title: ProfileContent.deleteAccountRowLabel,
                      destructive: true,
                      onTap: onDeleteAccount,
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
}
