import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/routes.dart';
import '../config/supabase_config.dart';
import '../config/theme.dart';
import '../features/home/widgets/illustration_placeholder.dart';
import '../features/auth/views/login_screen.dart';
import '../features/chat/providers/chat_providers.dart';
import '../features/chat/views/chat_list_screen.dart';
import '../features/chat/views/chat_room_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/matching/views/marketplace_screen.dart';
import '../features/matching/views/match_detail_screen.dart';
import '../features/matching/views/match_history_screen.dart';
import '../features/matching/views/profile_detail_screen.dart';
import '../features/contract/views/contract_history_screen.dart';
import '../features/home/views/client_registration_screen.dart';
import '../features/profile/views/my_client_detail_screen.dart';
import '../features/profile/views/my_client_edit_screen.dart';
import '../features/profile/views/my_clients_screen.dart';
import '../features/notification/views/notification_settings_screen.dart';
import '../features/profile/views/my_screen.dart';
import '../features/profile/views/customer_support_screen.dart';
import '../features/profile/views/crm_dashboard_screen.dart';
import '../features/subscription/views/subscription_screen.dart';
import '../features/verification/views/verification_screen.dart';
import '../shared/utils/auth_guard.dart';

part 'router.g.dart';

/// Global navigator key — shared with FcmService for deep linking
final rootNavigatorKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final user = ref.watch(currentUserProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = user != null;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (isAuthenticated && isAuthRoute) return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/matches',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my',
                builder: (context, state) => const MyScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/my/clients',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyClientsScreen(),
      ),
      GoRoute(
        path: '/my/clients/:clientId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => MyClientDetailScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/my/clients/:clientId/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => MyClientEditScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/my/subscription',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/my/notification-settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/my/match-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MatchHistoryScreen(),
      ),
      GoRoute(
        path: '/my/support',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CustomerSupportScreen(),
      ),
      GoRoute(
        path: '/my/crm-dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CrmDashboardScreen(),
      ),
      GoRoute(
        path: '/my/clients/:clientId/contracts',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ContractHistoryScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/matches/detail/:matchId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => MatchDetailScreen(
          matchId: state.pathParameters['matchId']!,
        ),
      ),
      GoRoute(
        path: '/marketplace/:profileId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra;
          final extraMap = extra is Map<String, dynamic> ? extra : null;
          return CustomTransitionPage(
            child: ProfileDetailScreen(
              profileId: state.pathParameters['profileId']!,
              hideMatchButton: extra == true || extraMap?['hideMatchButton'] == true,
              heroTagPrefix: extraMap?['heroPrefix'] as String? ?? 'all',
            ),
            transitionDuration: const Duration(milliseconds: 200),
            reverseTransitionDuration: const Duration(milliseconds: 350),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // 열릴 때: 빠른 fade-in, 닫힐 때: Hero 애니메이션 + fade-out
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/register-client',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: ClientRegistrationScreen(),
        ),
      ),
      GoRoute(
        path: '/verification',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VerificationScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ChatRoomScreen(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),
      GoRoute(
        path: '/auth',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );

  ref.onDispose(() => router.dispose());
  return router;
}

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final chatUnread = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: user == null ? null : _FloatingGlassNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) async {
          if (index >= 2) {
            if (!await requireAuth(context, ref)) return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          _NavItem(label: l10n.navHome, assetPath: 'assets/images/illustrations/nav_home.png'),
          _NavItem(label: l10n.navMatches, assetPath: 'assets/images/illustrations/nav_matches.png'),
          _NavItem(label: l10n.navChat, badgeCount: chatUnread, assetPath: 'assets/images/illustrations/nav_chat.png'),
          _NavItem(label: l10n.navMy, assetPath: 'assets/images/illustrations/nav_my.png'),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    this.badgeCount = 0,
    this.assetPath,
  });

  final String label;
  final int badgeCount;
  /// Path to illustration PNG (e.g. 'assets/images/illustrations/nav_home.png').
  /// Falls back to [IllustrationPlaceholder] when null.
  final String? assetPath;
}

class _FloatingGlassNavBar extends StatelessWidget {
  const _FloatingGlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Fill behind safe area with card color
      color: homeColors.cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Rounded island bar ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? homeColors.textPrimary.withValues(alpha: 0.06)
                  : homeColors.textPrimary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 56,
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: _NavTabItem(
                      item: items[i],
                      isSelected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Safe area bottom spacing
          SizedBox(height: bottomPadding > 0 ? bottomPadding - 4 : 8),
        ],
      ),
    );
  }
}

class _NavTabItem extends StatelessWidget {
  const _NavTabItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final homeColors = Theme.of(context).extension<HomeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = homeColors.pointColor;
    final mutedColor = homeColors.textPrimary.withValues(alpha: 0.3);

    // Build icon
    Widget iconWidget;
    if (item.assetPath != null) {
      iconWidget = Image.asset(
        item.assetPath!,
        width: 22,
        height: 22,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => IllustrationPlaceholder(
          width: 22,
          height: 22,
          color: isSelected ? activeColor : null,
        ),
      );

      if (!isSelected) {
        iconWidget = ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: Opacity(opacity: isDark ? 0.45 : 0.35, child: iconWidget),
        );
      }
    } else {
      iconWidget = IllustrationPlaceholder(
        width: 22,
        height: 22,
        color: isSelected ? activeColor : null,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 2),
            // Icon with lift + badge
            AnimatedSlide(
              offset: Offset(0, isSelected ? -0.08 : 0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                child: Badge(
                  isLabelVisible: item.badgeCount > 0,
                  label: Text(
                    item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                    style: const TextStyle(fontSize: 9),
                  ),
                  child: iconWidget,
                ),
              ),
            ),
            const SizedBox(height: 3),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : mutedColor,
                height: 1.2,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.errorNotFound, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(l10n.errorGoHome),
            ),
          ],
        ),
      ),
    );
  }
}
