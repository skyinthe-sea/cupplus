/// Centralized route path constants.
/// Always use these instead of hardcoded strings.
abstract final class AppRoutes {
  // Shell tabs
  static const home = '/';
  static const matches = '/matches';
  static const chat = '/chat';
  static const my = '/my';

  // Auth
  static const auth = '/auth';

  // Chat detail
  static String chatRoom(String conversationId) => '/chat/$conversationId';

  // Marketplace / Matching
  static String profileDetail(String profileId) => '/marketplace/$profileId';
  static String matchDetail(String matchId) => '/matches/detail/$matchId';

  // My tab sub-routes
  static const myClients = '/my/clients';
  static String myClientDetail(String clientId) => '/my/clients/$clientId';
  static String myClientEdit(String clientId) => '/my/clients/$clientId/edit';
  static const mySubscription = '/my/subscription';
  static const myNotificationSettings = '/my/notification-settings';
  static const myMatchHistory = '/my/match-history';
  static const mySupport = '/my/support';
  static const myCrmDashboard = '/my/crm-dashboard';

  // Full-screen overlays (pushed outside shell)
  static const clientRegistration = '/register-client';
  static const verification = '/verification';
  static String contractHistory(String clientId) =>
      '/my/clients/$clientId/contracts';
}
