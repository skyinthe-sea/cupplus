import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../shared/providers/locale_provider.dart';
import '../shared/providers/theme_mode_provider.dart';
import 'router.dart';

class CupPlusApp extends ConsumerWidget {
  const CupPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeNotifierProvider);

    return ScreenUtilInit(
      designSize: AppConstants.designSize,
      minTextAdapt: true,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: buildTheme(Brightness.light, lightDynamic),
              darkTheme: buildTheme(Brightness.dark, darkDynamic),
              themeMode: themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              routerConfig: router,
            );
          },
        );
      },
    );
  }
}
