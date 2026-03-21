import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_bubble.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../widgets/match_profile_sheet.dart';
import '../widgets/typing_indicator.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollController = ScrollController();
  late final SupabaseClient _supabaseClient;
  RealtimeChannel? _messageChannel;
  RealtimeChannel? _typingChannel;
  bool _isLoadingMore = false;
  bool _isMarkingRead = false;
  bool _isOtherTyping = false;
  Timer? _typingDebounce;
  Timer? _typingTimeout;
  DateTime? _lastSendTime;

  /// Keys for each message bubble, keyed by message ID.
  final _messageKeys = <String, GlobalKey>{};

  /// Message ID currently being highlighted (shake animation).
  String? _highlightedMessageId;

  GlobalKey _keyForMessage(String id) {
    return _messageKeys.putIfAbsent(id, () => GlobalKey());
  }

  @override
  void initState() {
    super.initState();
    _supabaseClient = ref.read(supabaseClientProvider);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markAsRead();
    });
    _subscribeToMessages();
    _subscribeToTyping();
  }

  void _subscribeToMessages() {
    final client = _supabaseClient;
    final user = client.auth.currentUser;
    if (user == null) return;

    _messageChannel = client
        .channel('room-${widget.conversationId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: widget.conversationId,
          ),
          callback: (payload) {
            if (!mounted) return;

            final newRecord = payload.newRecord;
            if (newRecord.isEmpty) return;

            final senderId = newRecord['sender_id'] as String?;
            if (senderId == user.id) return;

            var msg = ChatMessage.fromMap(newRecord, currentUserId: user.id);

            // Realtime payload doesn't include join data for reply_to.
            // Look up the referenced message from loaded messages to fill in reply data.
            if (msg.replyToId != null && msg.replyToContent == null) {
              msg = _enrichReplyData(msg);
            }

            ref
                .read(localMessagesProvider(widget.conversationId).notifier)
                .add(msg);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            _markAsRead();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: widget.conversationId,
          ),
          callback: (payload) {
            if (!mounted) return;

            final record = payload.newRecord;
            if (record.isEmpty) return;

            // Handle soft-delete updates
            final updatedMsg =
                ChatMessage.fromMap(record, currentUserId: user.id);
            ref
                .read(conversationMessagesProvider(widget.conversationId)
                    .notifier)
                .updateMessage(updatedMsg);
            ref
                .read(localMessagesProvider(widget.conversationId).notifier)
                .updateMessage(updatedMsg);
          },
        )
        .subscribe();
  }

  void _subscribeToTyping() {
    final client = _supabaseClient;
    final user = client.auth.currentUser;
    if (user == null) return;

    _typingChannel = client
        .channel('typing-${widget.conversationId}')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            if (!mounted) return;
            final senderId = payload['user_id'] as String?;
            if (senderId == null || senderId == user.id) return;

            setState(() => _isOtherTyping = true);

            // Auto-clear typing after 3 seconds of no new events
            _typingTimeout?.cancel();
            _typingTimeout = Timer(const Duration(seconds: 3), () {
              if (mounted) setState(() => _isOtherTyping = false);
            });
          },
        )
        .subscribe();
  }

  void _onTypingChanged(bool isTyping) {
    final user = _supabaseClient.auth.currentUser;
    if (user == null || _typingChannel == null) return;

    if (isTyping) {
      _sendTypingEvent(user.id);
      _typingDebounce?.cancel();
      _typingDebounce = Timer.periodic(const Duration(seconds: 2), (_) {
        if (mounted) _sendTypingEvent(user.id);
      });
    } else {
      _typingDebounce?.cancel();
      _typingDebounce = null;
    }
  }

  void _sendTypingEvent(String userId) {
    _typingChannel?.sendBroadcastMessage(
      event: 'typing',
      payload: {'user_id': userId},
    );
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadMoreMessages() async {
    final notifier = ref.read(
      conversationMessagesProvider(widget.conversationId).notifier,
    );
    if (!notifier.hasMore) return;

    _isLoadingMore = true;
    await notifier.loadMore();
    if (mounted) _isLoadingMore = false;
  }

  Future<void> _markAsRead() async {
    if (_isMarkingRead) return;
    _isMarkingRead = true;
    try {
      await ref.read(markAsReadProvider(widget.conversationId).future);
    } catch (_) {
    } finally {
      _isMarkingRead = false;
    }
  }

  @override
  void dispose() {
    if (_messageChannel != null) _supabaseClient.removeChannel(_messageChannel!);
    if (_typingChannel != null) _supabaseClient.removeChannel(_typingChannel!);
    _typingDebounce?.cancel();
    _typingTimeout?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Long-press action sheet ────────────────────────────────

  void _showMessageActions(ChatMessage message) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply (always available for non-deleted messages)
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: Text(l10n.chatReply),
              onTap: () {
                Navigator.pop(ctx);
                _setReply(message);
              },
            ),
            // Delete (only for own messages)
            if (message.isMine)
              ListTile(
                leading: Icon(Icons.delete_outline_rounded,
                    color: theme.colorScheme.error),
                title: Text(l10n.chatDeleteTitle,
                    style: TextStyle(color: theme.colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(message);
                },
              ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ChatMessage message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        icon: Icons.delete_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
        title: l10n.chatDeleteTitle,
        content: l10n.chatDeleteConfirm,
        cancelLabel: l10n.commonCancel,
        confirmLabel: l10n.commonDelete,
        isDestructive: true,
        onConfirm: () {
          Navigator.pop(context, true);
          _deleteMessage(message);
        },
      ),
    );
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    try {
      await ref.read(deleteMessageProvider(messageId: message.id).future);
    } catch (e, st) {
      debugPrint('Delete message failed: $e\n$st');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatDeleteFailed)),
      );
    }
  }

  // ─── Reply ─────────────────────────────────────────────────

  void _setReply(ChatMessage message) {
    ref
        .read(replyTargetProvider(widget.conversationId).notifier)
        .setReply(message);
  }

  void _clearReply() {
    ref.read(replyTargetProvider(widget.conversationId).notifier).clear();
  }

  /// Fill in reply data by looking up the referenced message from loaded messages.
  ChatMessage _enrichReplyData(ChatMessage msg) {
    if (msg.replyToId == null) return msg;

    final serverMsgs = ref.read(
        conversationMessagesProvider(widget.conversationId)).valueOrNull ?? [];
    final localMsgs = ref.read(
        localMessagesProvider(widget.conversationId));

    ChatMessage? replyTarget;
    for (final m in serverMsgs) {
      if (m.id == msg.replyToId) { replyTarget = m; break; }
    }
    replyTarget ??= localMsgs.where((m) => m.id == msg.replyToId).firstOrNull;

    if (replyTarget == null) return msg;

    return msg.copyWith(
      replyToContent: replyTarget.isDeleted ? null : replyTarget.content,
      replyToSenderId: replyTarget.senderId,
      replyToType: replyTarget.type,
      replyToIsDeleted: replyTarget.isDeleted,
    );
  }

  // ─── Scroll to message (reply tap) ────────────────────────

  Future<void> _scrollToMessage(String messageId) async {
    if (!_scrollController.hasClients) return;

    // Step 0: Find the target in loaded entries. Load more if needed.
    var entries = ref.read(chatRoomEntriesProvider(widget.conversationId));
    var targetIndex = _findEntryIndex(entries, messageId);

    if (targetIndex == -1) {
      final notifier = ref.read(
        conversationMessagesProvider(widget.conversationId).notifier,
      );
      for (var i = 0; i < 5 && notifier.hasMore; i++) {
        await notifier.loadMore();
        entries = ref.read(chatRoomEntriesProvider(widget.conversationId));
        targetIndex = _findEntryIndex(entries, messageId);
        if (targetIndex != -1) break;
      }
      if (targetIndex == -1) return;
    }

    // Step 1: If the target is already rendered on screen, just refine directly.
    if (_messageKeys[messageId]?.currentContext != null) {
      _refinePosition(messageId);
      _triggerHighlight(messageId);
      return;
    }

    // Step 2: Target is off-screen. Do a proportional jump to get close.
    final totalEntries = entries.length;
    final ratio = totalEntries > 1 ? targetIndex / (totalEntries - 1) : 0.0;
    final maxExtent = _scrollController.position.maxScrollExtent;
    _scrollController.jumpTo((ratio * maxExtent).clamp(0.0, maxExtent));

    // Step 3: Wait for render, then refine once.
    // Retry up to 5 times if the target isn't rendered yet.
    final viewportHeight = _scrollController.position.viewportDimension;
    for (var attempt = 0; attempt < 5; attempt++) {
      await _waitForFrame();
      if (_messageKeys[messageId]?.currentContext != null) {
        _refinePosition(messageId);
        _triggerHighlight(messageId);
        return;
      }
      // Not rendered yet — the proportional estimate undershot (images are tall).
      // Target is older = further UP in reversed list = higher offset.
      // Jump UP by one viewport height each attempt.
      final current = _scrollController.offset;
      _scrollController.jumpTo(
        (current + viewportHeight).clamp(0.0, maxExtent),
      );
    }

    // Best effort: highlight wherever we ended up
    _triggerHighlight(messageId);
  }

  void _triggerHighlight(String messageId) {
    if (!mounted) return;
    setState(() => _highlightedMessageId = messageId);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _highlightedMessageId = null);
    });
  }

  int _findEntryIndex(List<ChatListEntry> entries, String messageId) {
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      if (e is MessageEntry && e.message.id == messageId) return i;
    }
    return -1;
  }

  void _refinePosition(String messageId) {
    final key = _messageKeys[messageId];
    if (key?.currentContext == null) return;

    final targetBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (targetBox == null || !targetBox.hasSize) return;

    // Get the viewport's top position on screen (accounts for AppBar)
    final scrollable = Scrollable.of(key.currentContext!);
    final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    final viewportTopOnScreen = viewportBox.localToGlobal(Offset.zero).dy;
    final targetOnScreen = targetBox.localToGlobal(Offset.zero).dy;

    // Target position RELATIVE to viewport (not screen)
    final targetInViewport = targetOnScreen - viewportTopOnScreen;
    final viewportHeight = _scrollController.position.viewportDimension;

    // We want the target at ~35% from the top of the viewport
    final desiredY = viewportHeight * 0.35;
    final delta = targetInViewport - desiredY;

    // REVERSED list: increasing offset = viewport moves UP = items move DOWN.
    // To move the target UP in viewport (positive delta), we DECREASE offset.
    final newOffset = (_scrollController.offset - delta)
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.jumpTo(newOffset);
  }

  Future<void> _waitForFrame() {
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    return completer.future;
  }

  // ─── Send ──────────────────────────────────────────────────

  Future<void> _handleSend(String text) async {
    // Throttle: ignore sends within 300ms of the last one
    final now = DateTime.now();
    if (_lastSendTime != null &&
        now.difference(_lastSendTime!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastSendTime = now;

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    final replyTarget =
        ref.read(replyTargetProvider(widget.conversationId));
    final replyToId = replyTarget?.id;

    final localMsg = ChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: user.id,
      content: text,
      type: 'text',
      isRead: false,
      createdAt: DateTime.now(),
      isMine: true,
      replyToId: replyToId,
      replyToContent: replyTarget?.isDeleted == true
          ? null
          : replyTarget?.content,
      replyToSenderId: replyTarget?.senderId,
      replyToType: replyTarget?.type,
      replyToIsDeleted: replyTarget?.isDeleted,
    );

    ref
        .read(localMessagesProvider(widget.conversationId).notifier)
        .add(localMsg);

    // Clear reply state immediately
    _clearReply();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      await ref.read(sendMessageProvider(
        conversationId: widget.conversationId,
        content: text,
        replyToId: replyToId,
      ).future);
    } catch (e) {
      if (!mounted) return;
      ref
          .read(localMessagesProvider(widget.conversationId).notifier)
          .remove(localMsg.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.chatMessageSendFailed)),
      );
    }
  }

  Future<void> _handleImageSend() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                l10n.chatImagePickerTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.chatImagePickerCamera),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.chatImagePickerGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file == null || !mounted) return;

    // Compress with flutter_image_compress (better quality + EXIF removal)
    final compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
      format: CompressFormat.jpeg,
    );
    if (compressed == null || !mounted) return;

    // Throttle: ignore sends within 300ms of the last one (applied after picker/compress)
    final now = DateTime.now();
    if (_lastSendTime != null &&
        now.difference(_lastSendTime!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastSendTime = now;

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    final localMsg = ChatMessage(
      id: 'local-img-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: user.id,
      content: l10n.chatImageUploading,
      type: 'image',
      isRead: false,
      createdAt: DateTime.now(),
      isMine: true,
    );

    ref
        .read(localMessagesProvider(widget.conversationId).notifier)
        .add(localMsg);

    try {
      final storagePath = await ref.read(uploadChatImageProvider(
        conversationId: widget.conversationId,
        bytes: compressed.toList(),
      ).future);

      if (!mounted) return;

      // Cache compressed bytes so thumbnail renders instantly (no signed URL round-trip)
      final cacheKey = storagePath.replaceFirst('chat-images/', '');
      LocalImageCache.put(cacheKey, compressed);

      await ref.read(sendMessageProvider(
        conversationId: widget.conversationId,
        content: '',
        type: 'image',
        imageUrl: storagePath,
      ).future);

      // Replace local placeholder with a proper message (correct imageUrl, no local- prefix)
      if (!mounted) return;
      ref
          .read(localMessagesProvider(widget.conversationId).notifier)
          .replace(
            localMsg.id,
            ChatMessage(
              id: 'sent-${DateTime.now().millisecondsSinceEpoch}',
              conversationId: widget.conversationId,
              senderId: user.id,
              content: '',
              type: 'image',
              imageUrl: storagePath,
              isRead: false,
              createdAt: localMsg.createdAt,
              isMine: true,
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ref
          .read(localMessagesProvider(widget.conversationId).notifier)
          .remove(localMsg.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatMessageSendFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final messagesAsync = ref.watch(
      conversationMessagesProvider(widget.conversationId),
    );
    final conversation = ref.watch(
      conversationDetailProvider(widget.conversationId),
    );
    final entries = ref.watch(
      chatRoomEntriesProvider(widget.conversationId),
    );
    final replyTarget = ref.watch(
      replyTargetProvider(widget.conversationId),
    );

    final participantName = conversation?.participantName ?? '';
    final matchContext = conversation?.matchContext;
    final matchId = conversation?.matchId;
    final currentUserId = _supabaseClient.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1C20) : const Color(0xFFEBF1F8),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                participantName.characters.firstOrNull ?? '?',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participantName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (matchContext != null && matchId != null)
                    GestureDetector(
                      onTap: () => MatchProfileSheet.show(context, matchId),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              matchContext,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14.r,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      l10n.chatOffline,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (_) => ListView.builder(
                controller: _scrollController,
                reverse: true,
                cacheExtent: 1500, // Large cache so reply-scroll targets are rendered
                addAutomaticKeepAlives: false,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: entries.length + (_isOtherTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing indicator at position 0 (bottom of reversed list)
                  if (_isOtherTyping && index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 56.w,
                        right: 48.w,
                        top: 4.h,
                        bottom: 4.h,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surfaceContainer
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                              width: 0.5,
                            ),
                          ),
                          child: const TypingIndicator(),
                        ),
                      ),
                    );
                  }

                  final entryIndex = _isOtherTyping ? index - 1 : index;
                  final entry = entries[entryIndex];
                  return switch (entry) {
                    DateEntry(:final date) => DateSeparator(date: date),
                    MessageEntry(:final message, :final showAvatar) =>
                      _ShakeWrapper(
                        key: _keyForMessage(message.id),
                        isHighlighted: _highlightedMessageId == message.id,
                        child: MessageBubble(
                          message: message,
                          showAvatar: showAvatar,
                          participantName: participantName,
                          currentUserId: currentUserId,
                          onLongPress: !message.isDeleted
                              ? _showMessageActions
                              : null,
                          onReply: !message.isDeleted ? _setReply : null,
                          onScrollToMessage: _scrollToMessage,
                        ),
                      ),
                  };
                },
              ),
            ),
          ),
          ChatInputArea(
            onSend: _handleSend,
            onImageSend: _handleImageSend,
            onTypingChanged: _onTypingChanged,
            replyTarget: replyTarget,
            onReplyDismiss: _clearReply,
            replyTargetSenderName: replyTarget != null
                ? (replyTarget.isMine
                    ? AppLocalizations.of(context)!.chatReplyToMe
                    : participantName)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Shake highlight wrapper ─────────────────────────────────

class _ShakeWrapper extends StatefulWidget {
  const _ShakeWrapper({
    super.key,
    required this.isHighlighted,
    required this.child,
  });

  final bool isHighlighted;
  final Widget child;

  @override
  State<_ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends State<_ShakeWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // 3 quick shakes: left-right-left-right-center
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: -5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_ShakeWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
