import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../l10n/app_localizations.dart';

class LandingHome extends StatefulWidget {
  const LandingHome({super.key});

  @override
  State<LandingHome> createState() => _LandingHomeState();
}

class _LandingHomeState extends State<LandingHome>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _bgController;
  late final Animation<double> _heroOpacity;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _featuresOpacity;
  late final Animation<double> _ctaOpacity;
  late final Animation<Offset> _ctaSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    ));
    _featuresOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _ctaOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
    );
    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.55, 0.95, curve: Curves.easeOutCubic),
    ));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Floating orbs background
          RepaintBoundary(
            child: _LandingOrbs(
              animation: _bgController,
              screenSize: screenSize,
              colorScheme: cs,
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  // Logo
                  FadeTransition(
                    opacity: _heroOpacity,
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: 'cup',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.primary,
                          ),
                        ),
                        TextSpan(
                          text: '+',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.tertiary,
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Hero text
                  SlideTransition(
                    position: _heroSlide,
                    child: FadeTransition(
                      opacity: _heroOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.landingHeroTitle,
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            l10n.landingHeroSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Feature cards
                  FadeTransition(
                    opacity: _featuresOpacity,
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.auto_awesome_rounded,
                          color: cs.primary,
                          title: l10n.landingFeature1Title,
                          desc: l10n.landingFeature1Desc,
                        ),
                        SizedBox(height: 16.h),
                        _FeatureRow(
                          icon: Icons.chat_bubble_rounded,
                          color: cs.secondary,
                          title: l10n.landingFeature2Title,
                          desc: l10n.landingFeature2Desc,
                        ),
                        SizedBox(height: 16.h),
                        _FeatureRow(
                          icon: Icons.verified_rounded,
                          color: cs.tertiary,
                          title: l10n.landingFeature3Title,
                          desc: l10n.landingFeature3Desc,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // CTA
                  SlideTransition(
                    position: _ctaSlide,
                    child: FadeTransition(
                      opacity: _ctaOpacity,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: FilledButton(
                              onPressed: () => context.push(AppRoutes.auth),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(l10n.landingCta),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.landingLoginPrompt,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: cs.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push(AppRoutes.auth),
                                style: TextButton.styleFrom(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  l10n.authLogin,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 48.r,
          height: 48.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(icon, color: color, size: 24.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13.sp,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Soft floating gradient orbs for the landing background.
class _LandingOrbs extends StatelessWidget {
  const _LandingOrbs({
    required this.animation,
    required this.screenSize,
    required this.colorScheme,
  });

  final Animation<double> animation;
  final Size screenSize;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final h = screenSize.height;
    final tau = 2 * math.pi;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;

        return SizedBox.expand(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -100.r,
                top: h * 0.05,
                child: Transform.translate(
                  offset: Offset(
                    30 * math.sin(2 * tau * t),
                    25 * math.cos(3 * tau * t),
                  ),
                  child: _Orb(
                    size: 300.r,
                    color: colorScheme.primary,
                    opacity: 0.18,
                  ),
                ),
              ),
              Positioned(
                left: -80.r,
                bottom: h * 0.15,
                child: Transform.translate(
                  offset: Offset(
                    25 * math.cos(3 * tau * t + math.pi / 4),
                    35 * math.sin(2 * tau * t + math.pi / 3),
                  ),
                  child: _Orb(
                    size: 260.r,
                    color: colorScheme.tertiary,
                    opacity: 0.14,
                  ),
                ),
              ),
              Positioned(
                right: -40.r,
                top: h * 0.45,
                child: Transform.translate(
                  offset: Offset(
                    20 * math.sin(4 * tau * t + math.pi / 6),
                    28 * math.cos(3 * tau * t + math.pi / 2),
                  ),
                  child: _Orb(
                    size: 200.r,
                    color: colorScheme.secondary,
                    opacity: 0.12,
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

class _Orb extends StatelessWidget {
  const _Orb({
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
