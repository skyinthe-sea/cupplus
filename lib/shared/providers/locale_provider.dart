import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale build() => const Locale('ko', 'KR');

  void toggleLocale() {
    state = state.languageCode == 'ko'
        ? const Locale('en', 'US')
        : const Locale('ko', 'KR');
  }
}
