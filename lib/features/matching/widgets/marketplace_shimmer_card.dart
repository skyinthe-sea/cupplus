import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketplaceShimmerCard extends StatefulWidget {
  const MarketplaceShimmerCard({super.key});

  @override
  State<MarketplaceShimmerCard> createState() => _MarketplaceShimmerCardState();
}

class _MarketplaceShimmerCardState extends State<MarketplaceShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.55)
                  : theme.colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.45),
                width: 0.5,
              ),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _shimmerCircle(28.r * 2, theme, isDark),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _shimmerBox(120.w, 14.h, theme, isDark),
                              SizedBox(height: 6.h),
                              _shimmerBox(160.w, 11.h, theme, isDark),
                              SizedBox(height: 4.h),
                              _shimmerBox(100.w, 10.h, theme, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _shimmerBox(60.w, 20.h, theme, isDark),
                        SizedBox(width: 6.w),
                        _shimmerBox(40.w, 18.h, theme, isDark),
                        SizedBox(width: 4.w),
                        _shimmerBox(40.w, 18.h, theme, isDark),
                        SizedBox(width: 4.w),
                        _shimmerBox(40.w, 18.h, theme, isDark),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _shimmerBox(80.w, 10.h, theme, isDark),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, ThemeData theme, bool isDark) {
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerHighest;
    final highlightColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (_animation.value - 0.3).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCircle(double size, ThemeData theme, bool isDark) {
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surfaceContainerHighest;
    final highlightColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (_animation.value - 0.3).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
