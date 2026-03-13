import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  String _getGreeting(AppLocalizations l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return l10n.homeGreetingMorning(name);
    if (hour >= 12 && hour < 18) return l10n.homeGreetingAfternoon(name);
    if (hour >= 18 && hour < 22) return l10n.homeGreetingEvening(name);
    return l10n.homeGreetingNight(name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 8.h,
        bottom: 8.h,
      ),
      child: Text(
        _getGreeting(l10n, userName),
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
