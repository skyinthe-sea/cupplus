import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Logo fades in from 0→400ms
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.35, curve: Curves.easeOut),
      ),
    );

    // Text fades in from 300→700ms
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );

    // Text slides up slightly
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Auto-complete after animation + brief hold
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1814) : const Color(0xFFFAF8F5);
    final pointColor = isDark ? const Color(0xFFe06848) : const Color(0xFFc8523a);
    final textColor = isDark ? const Color(0xFFF0ECE6) : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            FadeTransition(
              opacity: _logoFade,
              child: Image.asset(
                'assets/splash/splashh.png',
                width: 240.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 28.h),
            // "cup+" text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'cup',
                        style: TextStyle(
                          fontFamily: serifFontFamily,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextSpan(
                        text: '+',
                        style: TextStyle(
                          fontFamily: serifFontFamily,
                          fontSize: 34.sp,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          color: pointColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
