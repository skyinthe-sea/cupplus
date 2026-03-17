import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/routes.dart';
import '../config/supabase_config.dart';
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
        builder: (context, state) => ProfileDetailScreen(
          profileId: state.pathParameters['profileId']!,
          hideMatchButton: state.extra == true,
        ),
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
    final chatUnread = ref.watch(totalUnreadCountProvider);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingGlassNavBar(
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
          _NavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.navHome,
          ),
          _NavItem(
            icon: Icons.favorite_outline_rounded,
            selectedIcon: Icons.favorite_rounded,
            label: l10n.navMatches,
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: l10n.navChat,
            badgeCount: chatUnread,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.navMy,
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
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
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding + 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainer
                      .withValues(alpha: 0.72)
                  : theme.colorScheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                return Expanded(
                  child: _GlassNavItem(
                    item: items[i],
                    isSelected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final mutedColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.55);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18 : 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Badge(
                isLabelVisible: item.badgeCount > 0,
                label: Text(
                  item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                  style: const TextStyle(fontSize: 10),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? primaryColor : mutedColor,
                  size: 28,
                ),
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 280),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? primaryColor : mutedColor,
              height: 1.2,
            ),
            child: Text(item.label),
          ),
        ],
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
