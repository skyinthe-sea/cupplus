import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_mode_provider.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../../../config/routes.dart';
import '../../verification/providers/verification_provider.dart';
import '../widgets/linked_accounts_section.dart';
import '../widgets/logout_button.dart';
import '../widgets/nickname_edit_dialog.dart';
import '../widgets/profile_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

String? _nonEmpty(String? s) => (s != null && s.trim().isNotEmpty) ? s : null;

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final managerProfile = ref.watch(managerProfileProvider);
    final locale = ref.watch(localeNotifierProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;
    final verificationStatus = ref.watch(managerVerificationStatusProvider);

    final nickname = managerProfile.valueOrNull?['nickname'] as String?;
    final managerName = managerProfile.valueOrNull?['full_name'] as String?;
    final fullName = _nonEmpty(managerName) ??
        _nonEmpty(user?.userMetadata?['full_name'] as String?) ??
        _nonEmpty(user?.email?.split('@').first) ??
        'User';
    final userName = _nonEmpty(nickname) ?? fullName;
    final userEmail = user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.w,
                  top: 16.h,
                  bottom: 20.h,
                ),
                child: Text(
                  l10n.navMy,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Profile Card
            SliverToBoxAdapter(
              child: ProfileCard(
                name: userName,
                subtitle: nickname == null ? l10n.nicknameSetHint : userEmail,
                email: userEmail,
                verificationStatus: verificationStatus.valueOrNull,
                onVerificationTap: () => _openVerification(context),
                onTap: () async {
                  final result = await NicknameEditDialog.show(
                    context,
                    currentNickname: nickname,
                  );
                  if (result == true) {
                    ref.invalidate(managerProfileProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.nicknameEditSuccess)),
                      );
                    }
                  }
                },
              ),
            ),

            // My Clients
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.myClients),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36.r,
                            height: 36.r,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.people_rounded,
                              size: 20.r,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              l10n.myClientsTitle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Settings Section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.mySettingsTitle),
            ),
            SliverToBoxAdapter(
              child: SettingsSection(
                children: [
                  SettingsTile(
                    icon: Icons.badge_outlined,
                    label: l10n.myNickname,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nickname ?? l10n.nicknameSetHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: nickname != null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20.r,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final result = await NicknameEditDialog.show(
                        context,
                        currentNickname: nickname,
                      );
                      if (result == true) {
                        ref.invalidate(managerProfileProvider);
                      }
                    },
                  ),
                  SettingsTile(
                    icon: Icons.language_rounded,
                    label: l10n.mySettingsLanguage,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale.languageCode == 'ko'
                              ? l10n.mySettingsLanguageKo
                              : l10n.mySettingsLanguageEn,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.swap_horiz_rounded,
                          size: 20.r,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                    onTap: () {
                      ref.read(localeNotifierProvider.notifier).toggleLocale();
                    },
                  ),
                  SettingsTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    label: l10n.mySettingsDarkMode,
                    trailing: Switch.adaptive(
                      value: _isDarkEnabled(themeMode, isDark),
                      onChanged: (_) {
                        ref
                            .read(themeModeNotifierProvider.notifier)
                            .toggleDarkMode();
                      },
                    ),
                    onTap: () {
                      ref
                          .read(themeModeNotifierProvider.notifier)
                          .toggleDarkMode();
                    },
                  ),
                ],
              ),
            ),

            // Linked Accounts Section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.myLinkedAccountsTitle),
            ),
            const SliverToBoxAdapter(
              child: LinkedAccountsSection(),
            ),

            // General Section
            SliverToBoxAdapter(
              child: SectionHeader(title: l10n.myGeneralTitle),
            ),
            SliverToBoxAdapter(
              child: SettingsSection(
                children: [
                  SettingsTile(
                    icon: Icons.analytics_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    label: l10n.crmDashboardTitle,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    onTap: () => context.push(AppRoutes.myCrmDashboard),
                  ),
                  SettingsTile(
                    icon: Icons.history_rounded,
                    label: l10n.myMatchHistory,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    onTap: () => context.push(AppRoutes.myMatchHistory),
                  ),
                  SettingsTile(
                    icon: Icons.credit_card_rounded,
                    iconColor: const Color(0xFF7B5EA7),
                    label: l10n.mySubscriptionManage,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    onTap: () => context.push(AppRoutes.mySubscription),
                  ),
                  SettingsTile(
                    icon: Icons.notifications_outlined,
                    label: l10n.myNotificationSettings,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    onTap: () => context.push(AppRoutes.myNotificationSettings),
                  ),
                  SettingsTile(
                    icon: Icons.headset_mic_outlined,
                    label: l10n.myCustomerSupport,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    onTap: () => context.push(AppRoutes.mySupport),
                  ),
                ],
              ),
            ),

            // Logout Button
            const SliverToBoxAdapter(
              child: LogoutButton(),
            ),

            // Bottom padding for floating nav bar
            SliverToBoxAdapter(
              child: SizedBox(height: 120.h),
            ),
          ],
        ),
      ),
    );
  }

  void _openVerification(BuildContext context) {
    context.push(AppRoutes.verification);
  }

  bool _isDarkEnabled(ThemeMode themeMode, bool currentIsDark) {
    return switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => currentIsDark,
    };
  }
}
