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

            final msg = ChatMessage.fromMap(newRecord, currentUserId: user.id);
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
      // Send immediately, then throttle to once every 2 seconds
      // This ensures the remote 3-second timeout is always reset
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

  Future<void> _handleSend(String text) async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    final localMsg = ChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: user.id,
      content: text,
      type: 'text',
      isRead: false,
      createdAt: DateTime.now(),
      isMine: true,
    );

    ref
        .read(localMessagesProvider(widget.conversationId).notifier)
        .add(localMsg);

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
      ).future);
    } catch (e) {
      if (!mounted) return;
      ref
          .read(localMessagesProvider(widget.conversationId).notifier)
          .remove(localMsg.id);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatMessageSendFailed)),
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

    final participantName = conversation?.participantName ?? '';
    final matchContext = conversation?.matchContext;

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
                  if (matchContext != null)
                    Text(
                      matchContext,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                    MessageEntry(:final message, :final showAvatar) => MessageBubble(
                        message: message,
                        showAvatar: showAvatar,
                        participantName: participantName,
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
          ),
        ],
      ),
    );
  }
}
