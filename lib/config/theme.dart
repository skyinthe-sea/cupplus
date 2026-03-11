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
    verified: Color(0xFF2D5A8E),
  );

  static const dark = StatusColors(
    pending: Color(0xFFFFD54F),
    accepted: Color(0xFF66BB6A),
    declined: Color(0xFFEF5350),
    verified: Color(0xFF5B8FC2),
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

const _seedColor = Color(0xFF2D5A8E);
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
        ? const Color(0xFFF8F9FD)
        : const Color(0xFF121316),
  );
}

ThemeData buildTheme(Brightness brightness, [ColorScheme? dynamicScheme]) {
  final colorScheme = dynamicScheme ?? _buildColorScheme(brightness);
  final statusColors = brightness == Brightness.light
      ? StatusColors.light
      : StatusColors.dark;

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    extensions: [statusColors],
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
