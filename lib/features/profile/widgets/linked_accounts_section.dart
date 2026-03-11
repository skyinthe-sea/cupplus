import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../../auth/providers/linked_identities_provider.dart';
import 'settings_section.dart';

class LinkedAccountsSection extends ConsumerWidget {
  const LinkedAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final identitiesAsync = ref.watch(linkedIdentitiesProvider);

    return identitiesAsync.when(
      loading: () => SettingsSection(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (identities) {
        final hasGoogle = identities.any((i) => i.provider == 'google');
        final hasKakao = identities.any((i) => i.provider == 'kakao');

        return SettingsSection(
          children: [
            _ProviderTile(
              providerName: 'Google',
              icon: Icons.g_mobiledata_rounded,
              iconColor: const Color(0xFF4285F4),
              isConnected: hasGoogle,
              connectedLabel: l10n.myLinkedAccountConnected,
              notConnectedLabel: l10n.myLinkedAccountNotConnected,
            ),
            _ProviderTile(
              providerName: 'Kakao',
              icon: Icons.chat_bubble_rounded,
              iconColor: const Color(0xFFFEE500),
              iconForeground: const Color(0xFF3C1E1E),
              isConnected: hasKakao,
              connectedLabel: l10n.myLinkedAccountConnected,
              notConnectedLabel: l10n.myLinkedAccountNotConnected,
            ),
          ],
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.providerName,
    required this.icon,
    required this.iconColor,
    this.iconForeground,
    required this.isConnected,
    required this.connectedLabel,
    required this.notConnectedLabel,
  });

  final String providerName;
  final IconData icon;
  final Color iconColor;
  final Color? iconForeground;
  final bool isConnected;
  final String connectedLabel;
  final String notConnectedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 18.r,
              color: iconForeground ?? iconColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              providerName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isConnected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16.r,
                  color: Colors.green,
                ),
                SizedBox(width: 4.w),
                Text(
                  connectedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else
            Text(
              notConnectedLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
