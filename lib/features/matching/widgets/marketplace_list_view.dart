import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../models/marketplace_profile.dart';
import '../widgets/marketplace_profile_card.dart';

class MarketplaceListView extends ConsumerStatefulWidget {
  const MarketplaceListView({
    super.key,
    required this.profiles,
    this.showDimForMatched = false,
    this.hasMore = false,
    this.onLoadMore,
    this.onRefresh,
  });

  final List<MarketplaceProfile> profiles;
  final bool showDimForMatched;
  final bool hasMore;
  final Future<void> Function()? onLoadMore;
  final Future<void> Function()? onRefresh;

  @override
  ConsumerState<MarketplaceListView> createState() =>
      _MarketplaceListViewState();
}

class _MarketplaceListViewState extends ConsumerState<MarketplaceListView>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _fadeAnimations = [];
  final List<Animation<Offset>> _slideAnimations = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(MarketplaceListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLen = widget.profiles.length;
    final oldLen = _controllers.length;
    if (newLen > oldLen) {
      // Add animations for NEW items
      _addAnimations(oldLen, newLen);
    } else if (newLen < oldLen) {
      // Dispose excess controllers to prevent leak
      for (var i = newLen; i < oldLen; i++) {
        _controllers[i].dispose();
      }
      _controllers.removeRange(newLen, oldLen);
      _fadeAnimations.removeRange(newLen, oldLen);
      _slideAnimations.removeRange(newLen, oldLen);
    }
  }

  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    // Trigger load more when within 200px of the bottom
    if (currentScroll >= maxScroll - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  void _initAnimations() {
    _addAnimations(0, widget.profiles.length);
  }

  void _addAnimations(int fromIndex, int toIndex) {
    for (var i = fromIndex; i < toIndex; i++) {
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

      // Stagger delay only for first 6 items of each batch
      final batchIndex = i - fromIndex;
      final delay = Duration(milliseconds: (batchIndex < 6 ? batchIndex : 6) * 60);
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
    _scrollController.dispose();
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extra item for loading indicator at bottom
    final itemCount = widget.profiles.length + (widget.hasMore ? 1 : 0);

    return RefreshIndicator(
      color: const Color(0xFFB4637A),
      onRefresh: widget.onRefresh ?? () async {},
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index >= widget.profiles.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final profile = widget.profiles[index];
          final isDimmed = widget.showDimForMatched &&
              profile.clientStatus != null &&
              profile.clientStatus != 'active';

          final card = MarketplaceProfileCard(
            profile: profile,
            isDimmed: isDimmed,
            onTap: () {
              context.push(AppRoutes.profileDetail(profile.id));
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
