import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../l10n/app_localizations.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _checkCtrl;
  late AnimationController _text1Ctrl;
  late AnimationController _text2Ctrl;
  late AnimationController _buttonsCtrl;

  late Animation<double> _bgOpacity;
  late Animation<double> _checkScale;
  late Animation<double> _text1Opacity;
  late Animation<Offset> _text1Slide;
  late Animation<double> _text2Opacity;
  late Animation<Offset> _text2Slide;
  late Animation<double> _buttonsOpacity;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _text1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _text2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _buttonsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bgOpacity = CurvedAnimation(
      parent: _bgCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Spring scale for checkmark: 0 -> 1.3 -> 1.0
    _checkScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut));

    _text1Opacity = CurvedAnimation(
      parent: _text1Ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _text1Slide = CurvedAnimation(
      parent: _text1Ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    _text2Opacity = CurvedAnimation(
      parent: _text2Ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _text2Slide = CurvedAnimation(
      parent: _text2Ctrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    _buttonsOpacity = CurvedAnimation(
      parent: _buttonsCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _buttonsSlide = CurvedAnimation(
      parent: _buttonsCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 0ms: fade background
    _bgCtrl.forward();

    // 100ms: checkmark scale up
    await Future.delayed(const Duration(milliseconds: 100));
    _checkCtrl.forward();
    HapticFeedback.mediumImpact();

    // 400ms: first text
    await Future.delayed(const Duration(milliseconds: 300));
    _text1Ctrl.forward();

    // 600ms: second text
    await Future.delayed(const Duration(milliseconds: 200));
    _text2Ctrl.forward();

    // 800ms: buttons
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonsCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _checkCtrl.dispose();
    _text1Ctrl.dispose();
    _text2Ctrl.dispose();
    _buttonsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _bgOpacity,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Checkmark icon
                ScaleTransition(
                  scale: _checkScale,
                  child: Container(
                    width: 100.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 80.r,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // "Registration Complete!" text
                FadeTransition(
                  opacity: _text1Opacity,
                  child: SlideTransition(
                    position: _text1Slide,
                    child: Text(
                      l10n.regSuccessTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // "{name} has been registered"
                FadeTransition(
                  opacity: _text2Opacity,
                  child: SlideTransition(
                    position: _text2Slide,
                    child: Text(
                      l10n.regSuccessMessage(widget.clientName),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Action buttons
                FadeTransition(
                  opacity: _buttonsOpacity,
                  child: SlideTransition(
                    position: _buttonsSlide,
                    child: Column(
                      children: [
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.profileDetail(widget.clientId));
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: Size(double.infinity, 52.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            l10n.regSuccessViewProfile,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.go(AppRoutes.home);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 52.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            l10n.regSuccessGoHome,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
