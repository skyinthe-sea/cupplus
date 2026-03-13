import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';
import '../../config/supabase_config.dart';
import '../../l10n/app_localizations.dart';

Future<bool> requireAuth(BuildContext context, WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user != null) return true;

  final l10n = AppLocalizations.of(context)!;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.authRequiredTitle),
      content: Text(l10n.authRequiredMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.push(AppRoutes.auth);
          },
          child: Text(l10n.authRequiredLogin),
        ),
      ],
    ),
  );

  return false;
}
