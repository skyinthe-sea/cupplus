import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';

class ChatInputArea extends StatefulWidget {
  const ChatInputArea({
    super.key,
    required this.onSend,
    this.onImageSend,
    this.onTypingChanged,
    this.replyTarget,
    this.onReplyDismiss,
    this.replyTargetSenderName,
  });

  final ValueChanged<String> onSend;
  final VoidCallback? onImageSend;
  final ValueChanged<bool>? onTypingChanged;
  final ChatMessage? replyTarget;
  final VoidCallback? onReplyDismiss;
  final String? replyTargetSenderName;

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(ChatInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-focus when reply target is set
    if (widget.replyTarget != null && oldWidget.replyTarget == null) {
      _focusNode.requestFocus();
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview bar
            if (widget.replyTarget != null)
              _ReplyPreview(
                message: widget.replyTarget!,
                onDismiss: widget.onReplyDismiss,
                l10n: l10n,
                senderName: widget.replyTargetSenderName,
              ),
            // Input row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: widget.onImageSend,
                    icon: Icon(
                      Icons.add_rounded,
                      color: const Color(0xFF7B5EA7),
                      size: 24.r,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 36.r,
                      minHeight: 36.r,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHigh
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: l10n.chatInputPlaceholder,
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _hasText ? _handleSend : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: _hasText
                            ? const Color(0xFF2D5A8E)
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_upward_rounded,
                        size: 20.r,
                        color: _hasText
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reply Preview Bar ───────────────────────────────────────

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.message,
    required this.l10n,
    this.onDismiss,
    this.senderName,
  });

  final ChatMessage message;
  final AppLocalizations l10n;
  final VoidCallback? onDismiss;
  final String? senderName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String preview;
    if (message.type == 'image') {
      preview = l10n.chatImageMessage;
    } else {
      preview = message.content.length > 60
          ? '${message.content.substring(0, 60)}...'
          : message.content;
    }

    final displayName = senderName ??
        (message.isMine ? l10n.chatReplyToMe : '?');

    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 8.w, top: 8.h, bottom: 4.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.chatReply} $displayName',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, size: 18.r),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
          ),
        ],
      ),
    );
  }
}
