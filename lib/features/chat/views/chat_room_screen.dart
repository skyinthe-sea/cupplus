import 'package:flutter/material.dart';
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

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _scrollController = ScrollController();
  RealtimeChannel? _messageChannel;
  bool _isLoadingMore = false;
  bool _isMarkingRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Mark as read on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markAsRead();
    });
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    final client = ref.read(supabaseClientProvider);
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
            if (senderId == user.id) return; // Skip own messages (already optimistic)

            final msg = ChatMessage.fromMap(newRecord, currentUserId: user.id);
            ref
                .read(localMessagesProvider(widget.conversationId).notifier)
                .add(msg);

            // Auto-scroll to bottom
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });

            // Mark as read (debounced)
            _markAsRead();
          },
        )
        .subscribe();
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
      // Silently fail — read status is non-critical
    } finally {
      _isMarkingRead = false;
    }
  }

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
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
      // Remove failed optimistic message
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
    final file = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    // Optimistic: show uploading placeholder
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
        bytes: bytes.toList(),
      ).future);

      await ref.read(sendMessageProvider(
        conversationId: widget.conversationId,
        content: '',
        type: 'image',
        imageUrl: storagePath,
      ).future);
    } catch (e) {
      if (!mounted) return;
      // Remove failed optimistic image message
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
    // Entries computed in provider — not recomputed on UI-only rebuilds
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
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
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
          ),
        ],
      ),
    );
  }
}
