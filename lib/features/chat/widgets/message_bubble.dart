import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import 'fullscreen_image_viewer.dart';

/// In-memory cache for just-sent images to avoid signed URL + download round-trips.
class LocalImageCache {
  LocalImageCache._();
  static final Map<String, Uint8List> _cache = {};

  static void put(String storagePath, Uint8List bytes) =>
      _cache[storagePath] = bytes;
  static Uint8List? get(String storagePath) => _cache[storagePath];
  static void remove(String storagePath) => _cache.remove(storagePath);
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = false,
    this.participantName,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String? participantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * 0.72;
    final timeText = _formatTime(message.createdAt);

    if (message.isMine) {
      return _MineBubble(
        message: message,
        theme: theme,
        maxWidth: maxWidth,
        timeText: timeText,
        l10n: l10n,
      );
    }
    return _OtherBubble(
      message: message,
      theme: theme,
      isDark: isDark,
      maxWidth: maxWidth,
      timeText: timeText,
      showAvatar: showAvatar,
      participantName: participantName,
      l10n: l10n,
    );
  }

  static String _formatTime(DateTime dateTime) {
    final h = dateTime.hour.toString().padLeft(2, '0');
    final m = dateTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MineBubble extends StatelessWidget {
  const _MineBubble({
    required this.message,
    required this.theme,
    required this.maxWidth,
    required this.timeText,
    required this.l10n,
  });

  final ChatMessage message;
  final ThemeData theme;
  final double maxWidth;
  final String timeText;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 48.w, right: 16.w, top: 2.h, bottom: 2.h),
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
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5A8E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(4.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: _buildContent(
                Colors.white,
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
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
    return Text(
      message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
    );
  }
}

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
  });

  final ChatMessage message;
  final ThemeData theme;
  final bool isDark;
  final double maxWidth;
  final String timeText;
  final bool showAvatar;
  final String? participantName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              child: _buildContent(
                theme.colorScheme.onSurface,
                theme.colorScheme.onSurfaceVariant,
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
    return Text(
      message.content,
      style: TextStyle(fontSize: 14.sp, color: textColor, height: 1.4),
    );
  }
}

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
