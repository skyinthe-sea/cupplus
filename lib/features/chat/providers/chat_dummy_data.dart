import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/chat_message.dart';
import '../models/conversation_summary.dart';

part 'chat_dummy_data.g.dart';

const _currentManagerId = 'manager-self';

@riverpod
List<ConversationSummary> allConversations(Ref ref) {
  final now = DateTime.now();
  return [
    ConversationSummary(
      id: 'conv-1',
      participantId: 'manager-1',
      participantName: '김지현 매니저',
      lastMessage: '네, 김서연님 프로필 공유드릴게요',
      lastMessageType: 'text',
      lastMessageAt: now.subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ConversationSummary(
      id: 'conv-2',
      participantId: 'manager-2',
      participantName: '박성호 매니저',
      lastMessage: '부산 쪽 회원 중 조건 맞는 분 있으실까요?',
      lastMessageType: 'text',
      lastMessageAt: now.subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
    ConversationSummary(
      id: 'conv-3',
      participantId: 'manager-3',
      participantName: '이수진 매니저',
      lastMessage: '',
      lastMessageType: 'image',
      lastMessageAt: now.subtract(const Duration(days: 1)),
      unreadCount: 1,
      isOnline: true,
    ),
    ConversationSummary(
      id: 'conv-4',
      participantId: 'manager-4',
      participantName: '최현우 매니저',
      lastMessage: '감사합니다, 확인해보겠습니다',
      lastMessageType: 'text',
      lastMessageAt: now.subtract(const Duration(days: 3)),
      unreadCount: 0,
      isOnline: false,
    ),
  ];
}

@riverpod
int totalUnreadCount(Ref ref) {
  return ref.watch(allConversationsProvider).fold(0, (sum, c) => sum + c.unreadCount);
}

@riverpod
List<ChatMessage> conversationMessages(Ref ref, String conversationId) {
  final now = DateTime.now();

  return switch (conversationId) {
    'conv-1' => _conv1Messages(now),
    'conv-2' => _conv2Messages(now),
    'conv-3' => _conv3Messages(now),
    'conv-4' => _conv4Messages(now),
    _ => [],
  };
}

List<ChatMessage> _conv1Messages(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    ChatMessage(
      id: 'c1-m1',
      conversationId: 'conv-1',
      senderId: _currentManagerId,
      content: '김지현 매니저님, 안녕하세요!',
      type: 'text',
      isRead: true,
      createdAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c1-m2',
      conversationId: 'conv-1',
      senderId: 'manager-1',
      content: '안녕하세요! 무엇을 도와드릴까요?',
      type: 'text',
      isRead: true,
      createdAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14, minutes: 5)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c1-m3',
      conversationId: 'conv-1',
      senderId: _currentManagerId,
      content: '이준호 회원(92년생, 삼성전자)과 매칭 가능한 여성 회원이 있으실까요?',
      type: 'text',
      isRead: true,
      createdAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14, minutes: 10)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c1-m4',
      conversationId: 'conv-1',
      senderId: 'manager-1',
      content: '네, 몇 분 있습니다. 선호 조건이 어떻게 되나요?',
      type: 'text',
      isRead: true,
      createdAt: today.subtract(const Duration(days: 1)).add(const Duration(hours: 14, minutes: 15)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c1-m5',
      conversationId: 'conv-1',
      senderId: _currentManagerId,
      content: '93~96년생, 서울 거주, 대졸 이상 희망하십니다.',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 9, minutes: 30)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c1-m6',
      conversationId: 'conv-1',
      senderId: _currentManagerId,
      content: '직업은 크게 상관없다고 하셨어요.',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 9, minutes: 31)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c1-m7',
      conversationId: 'conv-1',
      senderId: 'manager-1',
      content: '김서연님(95년생, 네이버 마케팅)이 조건에 맞을 것 같습니다.',
      type: 'text',
      isRead: false,
      createdAt: today.add(const Duration(hours: 10)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c1-m8',
      conversationId: 'conv-1',
      senderId: 'manager-1',
      content: '네, 김서연님 프로필 공유드릴게요',
      type: 'text',
      isRead: false,
      createdAt: now.subtract(const Duration(minutes: 5)),
      isMine: false,
    ),
  ];
}

List<ChatMessage> _conv2Messages(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    ChatMessage(
      id: 'c2-m1',
      conversationId: 'conv-2',
      senderId: 'manager-2',
      content: '안녕하세요, 서울 쪽 매니저님이시죠?',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 8)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c2-m2',
      conversationId: 'conv-2',
      senderId: _currentManagerId,
      content: '네, 맞습니다. 어떤 건으로 연락주셨나요?',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 8, minutes: 10)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c2-m3',
      conversationId: 'conv-2',
      senderId: 'manager-2',
      content: '부산에 90년생 외과 전문의 남성 회원이 계신데, 서울 여성 회원 중 매칭 가능한 분이 있을까요?',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 8, minutes: 15)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c2-m4',
      conversationId: 'conv-2',
      senderId: _currentManagerId,
      content: '네, 확인해보겠습니다. 회원분 선호 조건 알려주시겠어요?',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 8, minutes: 20)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c2-m5',
      conversationId: 'conv-2',
      senderId: 'manager-2',
      content: '92~96년생, 160cm 이상, 전문직 또는 대기업 희망합니다.',
      type: 'text',
      isRead: true,
      createdAt: today.add(const Duration(hours: 8, minutes: 25)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c2-m6',
      conversationId: 'conv-2',
      senderId: _currentManagerId,
      content: '부산 쪽 회원 중 조건 맞는 분 있으실까요?',
      type: 'text',
      isRead: true,
      createdAt: now.subtract(const Duration(hours: 2)),
      isMine: true,
    ),
  ];
}

List<ChatMessage> _conv3Messages(DateTime now) {
  final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  return [
    ChatMessage(
      id: 'c3-m1',
      conversationId: 'conv-3',
      senderId: 'manager-3',
      content: '매니저님, 최민수 회원 프로필 검토 부탁드립니다.',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 10)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c3-m2',
      conversationId: 'conv-3',
      senderId: _currentManagerId,
      content: '네, 보내주세요.',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 10, minutes: 5)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c3-m3',
      conversationId: 'conv-3',
      senderId: 'manager-3',
      content: '최민수님은 90년생, 외과 전문의이시고 프리미엄 회원이세요.',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 10, minutes: 10)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c3-m4',
      conversationId: 'conv-3',
      senderId: _currentManagerId,
      content: '박지은님(94년생, 변호사)과 매칭이 좋을 것 같아요.',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 11)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c3-m5',
      conversationId: 'conv-3',
      senderId: 'manager-3',
      content: '좋습니다! 프로필 카드 공유해주실 수 있나요?',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 11, minutes: 15)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c3-m6',
      conversationId: 'conv-3',
      senderId: _currentManagerId,
      content: '네, 지금 보내드릴게요.',
      type: 'text',
      isRead: true,
      createdAt: yesterday.add(const Duration(hours: 11, minutes: 20)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c3-m7',
      conversationId: 'conv-3',
      senderId: 'manager-3',
      content: '',
      type: 'image',
      imageUrl: 'chat-images/conv-3/c3-m7.jpg',
      isRead: false,
      createdAt: yesterday.add(const Duration(hours: 14)),
      isMine: false,
    ),
  ];
}

List<ChatMessage> _conv4Messages(DateTime now) {
  final threeDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3));
  return [
    ChatMessage(
      id: 'c4-m1',
      conversationId: 'conv-4',
      senderId: 'manager-4',
      content: '안녕하세요, 신규 회원 서류 인증 절차 문의드립니다.',
      type: 'text',
      isRead: true,
      createdAt: threeDaysAgo.add(const Duration(hours: 9)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c4-m2',
      conversationId: 'conv-4',
      senderId: _currentManagerId,
      content: '안녕하세요! 어떤 서류인가요?',
      type: 'text',
      isRead: true,
      createdAt: threeDaysAgo.add(const Duration(hours: 9, minutes: 10)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c4-m3',
      conversationId: 'conv-4',
      senderId: 'manager-4',
      content: '재직증명서와 학위증명서 인증이 필요한데, 어떤 형식으로 제출하면 되나요?',
      type: 'text',
      isRead: true,
      createdAt: threeDaysAgo.add(const Duration(hours: 9, minutes: 15)),
      isMine: false,
    ),
    ChatMessage(
      id: 'c4-m4',
      conversationId: 'conv-4',
      senderId: _currentManagerId,
      content: '앱 내 서류 인증 메뉴에서 사진 촬영 또는 갤러리 업로드하시면 됩니다. 자동으로 압축 처리됩니다.',
      type: 'text',
      isRead: true,
      createdAt: threeDaysAgo.add(const Duration(hours: 9, minutes: 25)),
      isMine: true,
    ),
    ChatMessage(
      id: 'c4-m5',
      conversationId: 'conv-4',
      senderId: 'manager-4',
      content: '감사합니다, 확인해보겠습니다',
      type: 'text',
      isRead: true,
      createdAt: threeDaysAgo.add(const Duration(hours: 9, minutes: 30)),
      isMine: false,
    ),
  ];
}
