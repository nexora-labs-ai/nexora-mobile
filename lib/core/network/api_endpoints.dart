abstract final class ApiEndpoints {
  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const refreshToken = '/auth/refresh';
  static const me = '/users/me';

  // ─── Users / Profile ──────────────────────────────────────────────────────
  static const profile = '/users/profile';
  static String userById(String id) => '/users/$id';

  // ─── Groups ───────────────────────────────────────────────────────────────
  static const groups = '/groups';
  static String groupById(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String groupInvite(String id) => '/groups/$id/invitations';
  static String groupInviteAccept(String token) => '/groups/invitations/$token/accept';
  static String groupInviteReject(String token) => '/groups/invitations/$token/reject';

  // ─── Expenses ─────────────────────────────────────────────────────────────
  static String expenses(String groupId) => '/groups/$groupId/expenses';
  static String expenseById(String groupId, String id) => '/groups/$groupId/expenses/$id';
  static String settlements(String groupId) => '/groups/$groupId/settlements';
  static String balances(String groupId) => '/groups/$groupId/balances';

  // ─── Itinerary ────────────────────────────────────────────────────────────
  static String itineraries(String groupId) => '/groups/$groupId/itineraries';
  static String itineraryById(String groupId, String id) => '/groups/$groupId/itineraries/$id';

  // ─── Recommendations ──────────────────────────────────────────────────────
  static String recommendations(String groupId) => '/groups/$groupId/recommendations';

  // ─── AI Chat ──────────────────────────────────────────────────────────────
  static const aiChatSessions = '/ai/sessions';
  static String aiChatMessages(String sessionId) => '/ai/sessions/$sessionId/messages';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
