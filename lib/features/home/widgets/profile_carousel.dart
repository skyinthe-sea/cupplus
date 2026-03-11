import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/client_summary.dart';
import 'profile_carousel_card.dart';

class ProfileCarousel extends ConsumerStatefulWidget {
  const ProfileCarousel({super.key, required this.clients});

  final List<ClientSummary> clients;

  @override
  ConsumerState<ProfileCarousel> createState() => _ProfileCarouselState();
}

class _ProfileCarouselState extends ConsumerState<ProfileCarousel>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85)
      ..addListener(_onPageChanged);

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    ));

    _entranceController.forward();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = _pageController.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            SizedBox(
              height: 210.h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.clients.length,
                itemBuilder: (context, index) {
                  final scale = _calculateScale(index);
                  return Transform.scale(
                    scale: scale,
                    child: ProfileCarouselCard(client: widget.clients[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.clients.length,
                (index) => _buildDot(index, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateScale(int index) {
    final diff = (_currentPage - index).abs();
    return (1 - (diff * 0.08)).clamp(0.92, 1.0);
  }

  Widget _buildDot(int index, ThemeData theme) {
    final isActive = index == _currentPage.round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: isActive ? 20.r : 6.r,
      height: 6.r,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3.r),
      ),
    );
  }
}
