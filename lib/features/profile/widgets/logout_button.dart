import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../notification/services/fcm_service.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: TextButton(
        onPressed: () => _showLogoutDialog(context, ref),
        child: Text(
          l10n.authLogout,
          style: TextStyle(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final errorColor = Theme.of(context).colorScheme.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        icon: Icons.logout_rounded,
        iconColor: errorColor,
        title: l10n.myLogoutConfirmTitle,
        content: l10n.myLogoutConfirmMessage,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.authLogout,
        isDestructive: true,
      ),
    );

    if (confirmed == true && context.mounted) {
      // Clean up FCM tokens before signing out
      await FcmService.removeTokens();
      await ref.read(supabaseClientProvider).auth.signOut();
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    }
  }
}
