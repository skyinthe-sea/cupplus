import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../models/marketplace_profile.dart';
import '../widgets/marketplace_profile_card.dart';

class MarketplaceListView extends StatefulWidget {
  const MarketplaceListView({super.key, required this.profiles});

  final List<MarketplaceProfile> profiles;

  @override
  State<MarketplaceListView> createState() => _MarketplaceListViewState();
}

class _MarketplaceListViewState extends State<MarketplaceListView>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(MarketplaceListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profiles.length != widget.profiles.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (var i = 0; i < widget.profiles.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );

      final fade = CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      _controllers.add(controller);
      _fadeAnimations.add(fade);
      _slideAnimations.add(slide);

      final delay = Duration(milliseconds: (i < 6 ? i : 6) * 60);
      Future.delayed(delay, () {
        if (mounted && i < _controllers.length) {
          _controllers[i].forward();
        }
      });
    }
  }

  void _disposeAnimations() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _fadeAnimations.clear();
    _slideAnimations.clear();
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFB4637A),
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: widget.profiles.length,
        itemBuilder: (context, index) {
          final card = MarketplaceProfileCard(
            profile: widget.profiles[index],
            onTap: () {
              context.push('/marketplace/${widget.profiles[index].id}');
            },
          );

          if (index >= _fadeAnimations.length) {
            return card;
          }

          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: card,
            ),
          );
        },
      ),
    );
  }
}
