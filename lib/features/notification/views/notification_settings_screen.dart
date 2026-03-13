import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleSetting(
    NotificationSettings current, {
    bool? matchNotifications,
    bool? messageNotifications,
    bool? verificationNotifications,
    bool? systemNotifications,
  }) async {
    final updated = current.copyWith(
      matchNotifications: matchNotifications,
      messageNotifications: messageNotifications,
      verificationNotifications: verificationNotifications,
      systemNotifications: systemNotifications,
    );

    await ref.read(
      updateNotificationSettingsProvider(updated).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettingsTitle),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: settingsAsync.when(
          data: (settings) => _buildSettingsList(settings, l10n, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.commonError)),
        ),
      ),
    );
  }

  Widget _buildSettingsList(
    NotificationSettings settings,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        // Description
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20.r,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  l10n.notificationSettingsDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // Match notifications
        _SettingTile(
          icon: Icons.favorite_rounded,
          iconColor: theme.colorScheme.tertiary,
          title: l10n.notificationSettingsMatch,
          subtitle: l10n.notificationSettingsMatchDesc,
          value: settings.matchNotifications,
          onChanged: (v) =>
              _toggleSetting(settings, matchNotifications: v),
          delay: 0,
        ),

        SizedBox(height: 8.h),

        // Message notifications
        _SettingTile(
          icon: Icons.chat_bubble_rounded,
          iconColor: theme.colorScheme.primary,
          title: l10n.notificationSettingsMessage,
          subtitle: l10n.notificationSettingsMessageDesc,
          value: settings.messageNotifications,
          onChanged: (v) =>
              _toggleSetting(settings, messageNotifications: v),
          delay: 1,
        ),

        SizedBox(height: 8.h),

        // Verification notifications
        _SettingTile(
          icon: Icons.verified_rounded,
          iconColor: theme.colorScheme.secondary,
          title: l10n.notificationSettingsVerification,
          subtitle: l10n.notificationSettingsVerificationDesc,
          value: settings.verificationNotifications,
          onChanged: (v) =>
              _toggleSetting(settings, verificationNotifications: v),
          delay: 2,
        ),

        SizedBox(height: 8.h),

        // System notifications
        _SettingTile(
          icon: Icons.campaign_rounded,
          iconColor: theme.colorScheme.onSurfaceVariant,
          title: l10n.notificationSettingsSystem,
          subtitle: l10n.notificationSettingsSystemDesc,
          value: settings.systemNotifications,
          onChanged: (v) =>
              _toggleSetting(settings, systemNotifications: v),
          delay: 3,
        ),

        SizedBox(height: 32.h),

        // FCM status banner
        _FcmStatusBanner(theme: theme, l10n: l10n),
      ],
    );
  }
}

class _SettingTile extends StatefulWidget {
  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.delay = 0,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final int delay;

  @override
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(Duration(milliseconds: 80 * widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: widget.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20.r,
                    color: widget.iconColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Switch.adaptive(
                  value: widget.value,
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FcmStatusBanner extends StatelessWidget {
  const _FcmStatusBanner({required this.theme, required this.l10n});

  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active_outlined,
            size: 20.r,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.notificationSettingsFcmNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
