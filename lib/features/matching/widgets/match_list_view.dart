import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/match_summary.dart';
import 'match_card.dart';

class MatchListView extends StatefulWidget {
  const MatchListView({super.key, required this.matches});

  final List<MatchSummary> matches;

  @override
  State<MatchListView> createState() => _MatchListViewState();
}

class _MatchListViewState extends State<MatchListView>
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
  void didUpdateWidget(MatchListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matches.length != widget.matches.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (var i = 0; i < widget.matches.length; i++) {
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
        // Placeholder for future refresh logic
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: widget.matches.length,
        itemBuilder: (context, index) {
          if (index >= _fadeAnimations.length) {
            return MatchCard(match: widget.matches[index]);
          }

          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: MatchCard(match: widget.matches[index]),
            ),
          );
        },
      ),
    );
  }
}
