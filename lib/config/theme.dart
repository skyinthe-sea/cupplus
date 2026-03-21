import 'package:flutter/material.dart';

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.pending,
    required this.accepted,
    required this.declined,
    required this.verified,
  });

  final Color pending;
  final Color accepted;
  final Color declined;
  final Color verified;

  static const light = StatusColors(
    pending: Color(0xFFF9A825),
    accepted: Color(0xFF2E7D32),
    declined: Color(0xFFC62828),
    verified: Color(0xFFc8523a),
  );

  static const dark = StatusColors(
    pending: Color(0xFFFFD54F),
    accepted: Color(0xFF66BB6A),
    declined: Color(0xFFEF5350),
    verified: Color(0xFFe06848),
  );

  @override
  StatusColors copyWith({
    Color? pending,
    Color? accepted,
    Color? declined,
    Color? verified,
  }) {
    return StatusColors(
      pending: pending ?? this.pending,
      accepted: accepted ?? this.accepted,
      declined: declined ?? this.declined,
      verified: verified ?? this.verified,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      pending: Color.lerp(pending, other.pending, t)!,
      accepted: Color.lerp(accepted, other.accepted, t)!,
      declined: Color.lerp(declined, other.declined, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
    );
  }
}

@immutable
class HomeColors extends ThemeExtension<HomeColors> {
  const HomeColors({
    required this.pendingCardBg,
    required this.pendingCardBgEnd,
    required this.ctaBar,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.pointColor,
  });

  final Color pendingCardBg;
  final Color pendingCardBgEnd;
  final Color ctaBar;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color pointColor;

  static const light = HomeColors(
    pendingCardBg: Color(0xFFFADCCF),
    pendingCardBgEnd: Color(0xFFF5CEBB),
    ctaBar: Color(0xFF2C2C2C),
    cardColor: Color(0xFFFFFFFF),
    borderColor: Color(0x12000000), // rgba(0,0,0,0.07)
    textPrimary: Color(0xFF1A1A1A),
    pointColor: Color(0xFFc8523a),
  );

  static const dark = HomeColors(
    pendingCardBg: Color(0xFF3A2820),
    pendingCardBgEnd: Color(0xFF2E2018),
    ctaBar: Color(0xFF1A1614),
    cardColor: Color(0xFF242018),
    borderColor: Color(0x12FFD2AA), // rgba(255,210,170,0.07)
    textPrimary: Color(0xFFF0ECE6),
    pointColor: Color(0xFFe06848),
  );

  @override
  HomeColors copyWith({
    Color? pendingCardBg,
    Color? pendingCardBgEnd,
    Color? ctaBar,
    Color? cardColor,
    Color? borderColor,
    Color? textPrimary,
    Color? pointColor,
  }) {
    return HomeColors(
      pendingCardBg: pendingCardBg ?? this.pendingCardBg,
      pendingCardBgEnd: pendingCardBgEnd ?? this.pendingCardBgEnd,
      ctaBar: ctaBar ?? this.ctaBar,
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      textPrimary: textPrimary ?? this.textPrimary,
      pointColor: pointColor ?? this.pointColor,
    );
  }

  @override
  HomeColors lerp(HomeColors? other, double t) {
    if (other is! HomeColors) return this;
    return HomeColors(
      pendingCardBg: Color.lerp(pendingCardBg, other.pendingCardBg, t)!,
      pendingCardBgEnd: Color.lerp(pendingCardBgEnd, other.pendingCardBgEnd, t)!,
      ctaBar: Color.lerp(ctaBar, other.ctaBar, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      pointColor: Color.lerp(pointColor, other.pointColor, t)!,
    );
  }
}

const _seedColor = Color(0xFFc8523a);
const _secondaryColor = Color(0xFF7B5EA7);
const _tertiaryColor = Color(0xFFB4637A);

ColorScheme _buildColorScheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  return base.copyWith(
    secondary: brightness == Brightness.light
        ? _secondaryColor
        : _secondaryColor.withValues(alpha: 0.8),
    tertiary: brightness == Brightness.light
        ? _tertiaryColor
        : _tertiaryColor.withValues(alpha: 0.8),
    surface: brightness == Brightness.light
        ? const Color(0xFFFAF8F5)
        : const Color(0xFF1C1814),
  );
}

const _fontFamily = 'Pretendard';
const serifFontFamily = 'NanumMyeongjo';

ThemeData buildTheme(Brightness brightness, [ColorScheme? dynamicScheme]) {
  final colorScheme = dynamicScheme ?? _buildColorScheme(brightness);
  final statusColors = brightness == Brightness.light
      ? StatusColors.light
      : StatusColors.dark;
  final homeColors = brightness == Brightness.light
      ? HomeColors.light
      : HomeColors.dark;

  return ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    colorScheme: colorScheme,
    extensions: [statusColors, homeColors],
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
    ),
  );
}
