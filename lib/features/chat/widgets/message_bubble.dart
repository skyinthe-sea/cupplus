import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import 'fullscreen_image_viewer.dart';

/// In-memory LRU cache for just-sent images (max 20 entries).
class LocalImageCache {
  LocalImageCache._();
  static final Map<String, Uint8List> _cache = {};
  static final List<String> _order = [];
  static const _maxSize = 20;

  static void put(String storagePath, Uint8List bytes) {
    // If already cached, move to end (most recent)
    _order.remove(storagePath);
    _cache[storagePath] = bytes;
    _order.add(storagePath);
    // Evict oldest if over limit
    while (_order.length > _maxSize) {
      final oldest = _order.removeAt(0);
      _cache.remove(oldest);
    }
  }

  static Uint8List? get(String storagePath) => _cache[storagePath];
  static void remove(String storagePath) {
    _cache.remove(storagePath);
    _order.remove(storagePath);
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
    this.participantName,
    this.onLongPress,
    this.onReply,
    this.onScrollToMessage,
    required this.currentUserId,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String? participantName;
  final ValueChanged<ChatMessage>? onLongPress;
  final ValueChanged<ChatMessage>? onReply;
  final ValueChanged<String>? onScrollToMessage;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.72;
    final timeText = _formatTime(message.createdAt);

    // Deleted message placeholder
    if (message.isDeleted) {
      return _DeletedMessagePlaceholder(
        message: message,
        theme: theme,
        isDark: isDark,
        showAvatar: showAvatar,
        participantName: participantName,
        l10n: l10n,
      );
    }

    // Resolve reply sender name from ID
    String? resolvedReplySenderName;
    if (message.replyToSenderId != null) {
      resolvedReplySenderName = message.replyToSenderId == currentUserId
          ? l10n.chatReplyToMe
          : (participantName ?? '?');
    }

    Widget bubble;
    if (message.isMine) {
      bubble = _MineBubble(
        message: message,
        theme: theme,
        maxWidth: maxWidth,
        timeText: timeText,
        l10n: l10n,
        onLongPress: onLongPress != null ? () => onLongPress!(message) : null,
        onScrollToMessage: onScrollToMessage,
        replySenderName: resolvedReplySenderName,
      );
    } else {
      bubble = _OtherBubble(
        message: message,
        theme: theme,
        isDark: isDark,
        maxWidth: maxWidth,
        timeText: timeText,
        showAvatar: showAvatar,
        participantName: participantName,
        l10n: l10n,
        onLongPress: onLongPress != null ? () => onLongPress!(message) : null,
        onScrollToMessage: onScrollToMessage,
        replySenderName: resolvedReplySenderName,
      );
    }

    // Wrap with swipe-to-reply
    if (onReply != null) {
      return _SwipeToReply(
        onReply: () => onReply!(message),
        child: bubble,
      );
    }

    return bubble;
  }

  static String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ─── Swipe to Reply ──────────────────────────────────────────

class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({required this.onReply, required this.child});

  final VoidCallback onReply;
  final Widget child;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragExtent = 0;
  static const _threshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _dragExtent += details.delta.dx;
        if (_dragExtent < 0) _dragExtent = 0;
        if (_dragExtent > _threshold * 1.5) _dragExtent = _threshold * 1.5;
        _controller.value = _dragExtent / (_threshold * 1.5);
      },
      onHorizontalDragEnd: (_) {
        if (_dragExtent >= _threshold) {
          widget.onReply();
        }
        _dragExtent = 0;
        _controller.animateTo(0, curve: Curves.easeOut);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final offset = _controller.value * _threshold * 1.5;
          return Stack(
            children: [
              if (offset > 10)
                Positioned(
                  left: 8.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Opacity(
                      opacity: (offset / _threshold).clamp(0.0, 1.0),
                      child: Icon(
                        Icons.reply_rounded,
                        size: 20.r,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ─── Deleted Message Placeholder ─────────────────────────────

class _DeletedMessagePlaceholder extends StatelessWidget {
  const _DeletedMessagePlaceholder({
    required this.message,
    required this.theme,
    required this.isDark,
    required this.showAvatar,
    this.participantName,
    required this.l10n,
  });

  final ChatMessage message;
  final ThemeData theme;
  final bool isDark;
  final bool showAvatar;
  final String? participantName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Padding(
      padding: EdgeInsets.only(
        left: isMine ? 48.w : 16.w,
        right: isMine ? 16.w : 48.w,
        top: 2.h,
        bottom: 2.h,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16.r,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  participantName?.characters.first ?? '?',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              )
            else
              SizedBox(width: 32.r),
            SizedBox(width: 8.w),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: (isDark
                      ? theme.colorScheme.surfaceContainer
                      : Colors.grey.shade200)
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.block_rounded,
                  size: 14.r,
                  color:
                      theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                SizedBox(width: 4.w),
                Text(
                  l10n.chatMessageDeleted,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reply Quote Widget ──────────────────────────────────────

class ReplyQuote extends StatelessWidget {
  const ReplyQuote({
    super.key,
    required this.senderName,
    required this.content,
    required this.type,
    required this.isDeleted,
    required this.isMine,
    required this.l10n,
    this.onTap,
  });

  final String senderName;
  final String? content;
  final String? type;
  final bool isDeleted;
  final bool isMine; // Whether the parent bubble is mine (affects colors)
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = isMine
        ? Colors.white.withValues(alpha: 0.6)
        : theme.colorScheme.primary;

    String previewText;
    if (isDeleted) {
      previewText = l10n.chatMessageDeleted;
    } else if (type == 'image') {
      previewText = l10n.chatImageMessage;
    } else {
      final text = content ?? '';
      previewText = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 4.h, bottom: 4.h),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.white.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8.r),
          border: Border(
            left: BorderSide(color: barColor, width: 2.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.8)
                    : theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              previewText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                color: isMine
                    ? Colors.white.withValues(alpha: 0.6)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mine Bubble ─────────────────────────────────────────────

class _MineBubble extends StatelessWidget {
  const _MineBubble({
    required this.message,
    required this.theme,
    required this.maxWidth,
    required this.timeText,
    required this.l10n,
    this.onLongPress,
    this.onScrollToMessage,
    this.replySenderName,
  });

  final ChatMessage message;
  final ThemeData theme;
  final double maxWidth;
  final String timeText;
  final AppLocalizations l10n;
  final VoidCallback? onLongPress;
  final ValueChanged<String>? onScrollToMessage;
  final String? replySenderName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding:
            EdgeInsets.only(left: 48.w, right: 16.w, top: 2.h, bottom: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4.w, bottom: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14.r,
                    color: message.isRead
                        ? const Color(0xFF2D5A8E)
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5A8E),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(4.r),
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.replyToId != null)
                      ReplyQuote(
                        senderName: replySenderName ?? '?',
                        content: message.replyToContent,
                        type: message.replyToType,
                        isDeleted: message.replyToIsDeleted ?? false,
                        isMine: true,
                        l10n: l10n,
                        onTap: onScrollToMessage != null && message.replyToId != null
                            ? () => onScrollToMessage!(message.replyToId!)
                            : null,
                      ),
                    _buildContent(
                      Colors.white,
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color textColor, Color secondaryColor) {
    if (message.type == 'image') {
      return _ImageContent(
        message: message,
        l10n: l10n,
        secondaryColor: secondaryColor,
      );
    }
    return _ExpandableText(
      text: message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
      l10n: l10n,
    );
  }
}

// ─── Other Bubble ────────────────────────────────────────────

class _OtherBubble extends StatelessWidget {
  const _OtherBubble({
    required this.message,
    required this.theme,
    required this.isDark,
    required this.maxWidth,
    required this.timeText,
    required this.showAvatar,
    this.participantName,
    required this.l10n,
    this.onLongPress,
    this.onScrollToMessage,
    this.replySenderName,
  });

  final ChatMessage message;
  final ThemeData theme;
  final bool isDark;
  final double maxWidth;
  final String timeText;
  final bool showAvatar;
  final String? participantName;
  final AppLocalizations l10n;
  final VoidCallback? onLongPress;
  final ValueChanged<String>? onScrollToMessage;
  final String? replySenderName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
      padding: EdgeInsets.only(left: 16.w, right: 48.w, top: 2.h, bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showAvatar)
            CircleAvatar(
              radius: 16.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                participantName?.characters.first ?? '?',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            )
          else
            SizedBox(width: 32.r),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainer
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.replyToId != null)
                    ReplyQuote(
                      senderName: replySenderName ?? '?',
                      content: message.replyToContent,
                      type: message.replyToType,
                      isDeleted: message.replyToIsDeleted ?? false,
                      isMine: false,
                      l10n: l10n,
                      onTap: onScrollToMessage != null && message.replyToId != null
                          ? () => onScrollToMessage!(message.replyToId!)
                          : null,
                    ),
                  _buildContent(
                    theme.colorScheme.onSurface,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 2.h),
            child: Text(
              timeText,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildContent(Color textColor, Color secondaryColor) {
    if (message.type == 'image') {
      return _ImageContent(
        message: message,
        l10n: l10n,
        secondaryColor: secondaryColor,
      );
    }
    return _ExpandableText(
      text: message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
      l10n: l10n,
    );
  }
}

// ─── Image Content ───────────────────────────────────────────

class _ImageContent extends StatelessWidget {
  const _ImageContent({
    required this.message,
    required this.l10n,
    required this.secondaryColor,
  });

  final ChatMessage message;
  final AppLocalizations l10n;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    // Local upload in progress
    if (message.id.startsWith('local-')) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.r,
            height: 14.r,
            child: CircularProgressIndicator(strokeWidth: 2, color: secondaryColor),
          ),
          SizedBox(width: 6.w),
          Text(
            l10n.chatImageUploading,
            style: TextStyle(fontSize: 13.sp, color: secondaryColor),
          ),
        ],
      );
    }

    final imageUrl = message.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 16.r, color: secondaryColor),
          SizedBox(width: 4.w),
          Text(
            l10n.chatImageMessage,
            style: TextStyle(fontSize: 14.sp, color: secondaryColor),
          ),
        ],
      );
    }

    // Use signed URL for private bucket access
    final storagePath = imageUrl.replaceFirst('chat-images/', '');
    return _SignedImageWidget(
      storagePath: storagePath,
      secondaryColor: secondaryColor,
      l10n: l10n,
    );
  }
}

class _SignedImageWidget extends StatefulWidget {
  const _SignedImageWidget({
    required this.storagePath,
    required this.secondaryColor,
    required this.l10n,
  });

  final String storagePath;
  final Color secondaryColor;
  final AppLocalizations l10n;

  @override
  State<_SignedImageWidget> createState() => _SignedImageWidgetState();
}

class _SignedImageWidgetState extends State<_SignedImageWidget>
    with SingleTickerProviderStateMixin {
  String? _signedUrl;
  bool _hasError = false;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    // If cached locally (just-sent), show immediately
    if (LocalImageCache.get(widget.storagePath) != null) {
      _fadeController.value = 1.0;
    }
    _loadSignedUrl();
  }

  @override
  void didUpdateWidget(_SignedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storagePath != widget.storagePath) {
      _signedUrl = null;
      _hasError = false;
      if (LocalImageCache.get(widget.storagePath) != null) {
        _fadeController.value = 1.0;
      } else {
        _fadeController.value = 0;
      }
      _loadSignedUrl();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSignedUrl() async {
    try {
      final url = await Supabase.instance.client.storage
          .from('chat-images')
          .createSignedUrl(widget.storagePath, 3600);
      if (mounted) {
        setState(() => _signedUrl = url);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cachedBytes = LocalImageCache.get(widget.storagePath);
    final heroTag = 'chat-image-${widget.storagePath}';

    // Show from memory cache instantly (just-sent images)
    if (cachedBytes != null) {
      return GestureDetector(
        onTap: _signedUrl != null
            ? () => FullscreenImageViewer.show(
                  context,
                  imageUrl: _signedUrl!,
                  heroTag: heroTag,
                )
            : null,
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
              child: Image.memory(
                cachedBytes,
                fit: BoxFit.cover,
                cacheWidth: 400,
              ),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, size: 16.r, color: widget.secondaryColor),
          SizedBox(width: 4.w),
          Text(
            widget.l10n.chatImageMessage,
            style: TextStyle(fontSize: 14.sp, color: widget.secondaryColor),
          ),
        ],
      );
    }

    if (_signedUrl == null) {
      return SizedBox(
        width: 150.w,
        height: 100.h,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return GestureDetector(
      onTap: () => FullscreenImageViewer.show(
        context,
        imageUrl: _signedUrl!,
        heroTag: heroTag,
      ),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
            child: Image.network(
              _signedUrl!,
              fit: BoxFit.cover,
              cacheWidth: 400,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                if (frame != null) {
                  _fadeController.forward();
                  return FadeTransition(opacity: _fadeAnimation, child: child);
                }
                return SizedBox(
                  width: 150.w,
                  height: 100.h,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined, size: 16.r, color: widget.secondaryColor),
                  SizedBox(width: 4.w),
                  Text(
                    widget.l10n.chatImageMessage,
                    style: TextStyle(fontSize: 14.sp, color: widget.secondaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Expandable Text (long message collapse/expand) ─────────

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    required this.style,
    required this.l10n,
  });

  final String text;
  final TextStyle style;
  final AppLocalizations l10n;
  static const _maxLines = 8;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText>
    with AutomaticKeepAliveClientMixin {
  bool _expanded = false;
  bool? _exceeds;
  double _lastMaxWidth = 0;

  @override
  bool get wantKeepAlive => _expanded;

  void _measureIfNeeded(double maxWidth) {
    if (_exceeds != null &&
        _lastMaxWidth == maxWidth &&
        widget.text == widget.text) {
      return;
    }
    _lastMaxWidth = maxWidth;
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: _ExpandableText._maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    _exceeds = textPainter.didExceedMaxLines;
  }

  @override
  void didUpdateWidget(_ExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _exceeds = null; // invalidate cache
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return LayoutBuilder(
      builder: (context, constraints) {
        _measureIfNeeded(constraints.maxWidth);

        if (_exceeds != true) {
          return Text(widget.text, style: widget.style);
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: widget.style,
                maxLines: _expanded ? null : _ExpandableText._maxLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _expanded = !_expanded;
                  updateKeepAlive();
                }),
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    _expanded
                        ? widget.l10n.chatShowLess
                        : widget.l10n.chatShowMore,
                    style: widget.style.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
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
