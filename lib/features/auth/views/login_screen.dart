import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_notifier.dart';
import '../providers/last_login_provider.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  static const _devAccounts = [
    {'email': 'manager.kim@test.com', 'name': '김서연 매니저'},
    {'email': 'manager.park@test.com', 'name': '박지훈 매니저'},
  ];

  // Entrance animations
  late final AnimationController _controller;
  late final Animation<double> _brandOpacity;
  late final Animation<double> _actionsOpacity;
  late final Animation<Offset> _actionsSlide;
  late final Animation<double> _termsOpacity;
  late final Animation<double> _bgFadeIn;

  // Background orb animation
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _brandOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _actionsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    );
    _actionsSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
    ));
    _termsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _bgFadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _controller.forward();

    // Continuous loop for floating orbs
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String provider) async {
    final l10n = AppLocalizations.of(context)!;
    final lastUsed = ref.read(lastLoginNotifierProvider);
    if (lastUsed != null && lastUsed != provider) {
      final providerName =
          lastUsed == 'google' ? 'Google' : lastUsed == 'kakao' ? 'Kakao' : lastUsed;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.authDifferentProviderTitle),
          content: Text(l10n.authDifferentProviderMessage(providerName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    final notifier = ref.read(authNotifierProvider.notifier);
    switch (provider) {
      case 'kakao':
        notifier.signInWithKakao();
      case 'google':
        notifier.signInWithGoogle();
    }
  }

  Widget _buildDebugActionsWithSocial(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme cs,
    bool isLoading,
    String? lastLogin,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Social login buttons (same as release)
        SocialLoginButton(
          provider: SocialLoginProvider.kakao,
          isLoading: isLoading,
          isLastUsed: lastLogin == 'kakao',
          onPressed: () => _handleLogin('kakao'),
        ),
        SizedBox(height: 12.h),
        SocialLoginButton(
          provider: SocialLoginProvider.google,
          isLoading: isLoading,
          isLastUsed: lastLogin == 'google',
          onPressed: () => _handleLogin('google'),
        ),
        SizedBox(height: 20.h),
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                thickness: 0.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'DEV',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.outline.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                thickness: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        // Dev login buttons — 3 test accounts
        ..._devAccounts.map((acct) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => ref
                            .read(authNotifierProvider.notifier)
                            .devSignIn(acct['email']!),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    side: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 18.r),
                      SizedBox(width: 8.w),
                      Text(
                        '${acct['name']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        acct['email']!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildReleaseActions(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme cs,
    bool isLoading,
    String? lastLogin,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SocialLoginButton(
          provider: SocialLoginProvider.kakao,
          isLoading: isLoading,
          isLastUsed: lastLogin == 'kakao',
          onPressed: () => _handleLogin('kakao'),
        ),
        SizedBox(height: 12.h),
        SocialLoginButton(
          provider: SocialLoginProvider.google,
          isLoading: isLoading,
          isLastUsed: lastLogin == 'google',
          onPressed: () => _handleLogin('google'),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                thickness: 0.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                l10n.authOr,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.outline.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: cs.outlineVariant.withValues(alpha: 0.4),
                thickness: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: cs.onSurfaceVariant,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
          child: Text(
            l10n.authLoginWithEmail,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenSize = MediaQuery.sizeOf(context);
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;
    final lastLogin = ref.watch(lastLoginNotifierProvider);

    ref.listen(authNotifierProvider, (_, next) {
      if (next is AsyncError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authLoginError)),
        );
      }
      if (next is AsyncData && next != const AsyncData(null)) {
        if (context.mounted) Navigator.of(context).pop();
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Floating gradient orbs background
          FadeTransition(
            opacity: _bgFadeIn,
            child: RepaintBoundary(
              child: _FloatingOrbs(
                animation: _bgController,
                screenSize: screenSize,
                colorScheme: cs,
              ),
            ),
          ),

          // Foreground content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  // Brand zone
                  FadeTransition(
                    opacity: _brandOpacity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "cup+" wordmark — "+" in accent color
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'cup',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              TextSpan(
                                text: '+',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.tertiary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          l10n.authSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 6),

                  // Action buttons (bottom-anchored)
                  SlideTransition(
                    position: _actionsSlide,
                    child: FadeTransition(
                      opacity: _actionsOpacity,
                      child: kDebugMode
                          ? _buildDebugActionsWithSocial(l10n, theme, cs, isLoading, lastLogin)
                          : _buildReleaseActions(l10n, theme, cs, isLoading, lastLogin),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Terms notice — bottom-anchored
                  FadeTransition(
                    opacity: _termsOpacity,
                    child: Text(
                      l10n.authTermsNotice,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        fontSize: 11.sp,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three soft gradient orbs that float in slow Lissajous-like paths.
/// Uses RadialGradient + Transform.translate only — no blur filters.
class _FloatingOrbs extends StatelessWidget {
  const _FloatingOrbs({
    required this.animation,
    required this.screenSize,
    required this.colorScheme,
  });

  final Animation<double> animation;
  final Size screenSize;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final w = screenSize.width;
    final h = screenSize.height;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        final tau = 2 * math.pi;

        return SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Orb 1 — Primary deep blue, upper right
              // Lissajous: 2:3 ratio
              Positioned(
                right: -80.r,
                top: h * 0.08,
                child: Transform.translate(
                  offset: Offset(
                    40 * math.sin(2 * tau * t),
                    30 * math.cos(3 * tau * t),
                  ),
                  child: _GlowOrb(
                    size: 320.r,
                    color: colorScheme.primary,
                    opacity: 0.25,
                  ),
                ),
              ),
              // Orb 2 — Dusty rose, lower left
              // Lissajous: 3:2 ratio, phase-shifted
              Positioned(
                left: -60.r,
                bottom: h * 0.12,
                child: Transform.translate(
                  offset: Offset(
                    35 * math.cos(3 * tau * t + math.pi / 4),
                    45 * math.sin(2 * tau * t + math.pi / 3),
                  ),
                  child: _GlowOrb(
                    size: 280.r,
                    color: colorScheme.tertiary,
                    opacity: 0.20,
                  ),
                ),
              ),
              // Orb 3 — Muted violet, center
              // Lissajous: 4:3 ratio, phase-shifted
              Positioned(
                left: w * 0.15,
                top: h * 0.38,
                child: Transform.translate(
                  offset: Offset(
                    30 * math.sin(4 * tau * t + math.pi / 6),
                    35 * math.cos(3 * tau * t + math.pi / 2),
                  ),
                  child: _GlowOrb(
                    size: 240.r,
                    color: colorScheme.secondary,
                    opacity: 0.15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.7],
        ),
      ),
    );
  }
}
