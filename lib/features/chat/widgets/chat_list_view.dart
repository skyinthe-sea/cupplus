import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../models/conversation_summary.dart';
import 'chat_list_item.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({
    super.key,
    required this.conversations,
    this.onRefresh,
  });

  final List<ConversationSummary> conversations;
  final Future<void> Function()? onRefresh;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView>
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
  void didUpdateWidget(ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversations.length != widget.conversations.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _initAnimations() {
    for (var i = 0; i < widget.conversations.length; i++) {
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
      onRefresh: widget.onRefresh ?? () async {},
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 120.h),
        itemCount: widget.conversations.length,
        itemBuilder: (context, index) {
          final conversation = widget.conversations[index];
          final item = ChatListItem(
            conversation: conversation,
            onTap: () => context.push(AppRoutes.chatRoom(conversation.id)),
          );

          if (index >= _fadeAnimations.length) return item;

          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: item,
            ),
          );
        },
      ),
    );
  }
}
