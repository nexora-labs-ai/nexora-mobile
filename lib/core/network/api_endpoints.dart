abstract final class ApiEndpoints {
  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const logout = '/auth/logout';
  static const refreshToken = '/auth/refresh';
  static const me = '/users/me';
  static const mezonLogin = '/auth/mezon';

  // ─── Users / Profile ──────────────────────────────────────────────────────
  static const profile = '/users/profile';
  static String userById(String id) => '/users/$id';

  // ─── Groups ───────────────────────────────────────────────────────────────
  static const groups = '/groups';
  static String groupById(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String groupInvite(String id) => '/groups/$id/invitations';
  static String groupInviteAccept(String token) =>
      '/groups/invitations/$token/accept';
  static String groupInviteReject(String token) =>
      '/groups/invitations/$token/reject';
  static String groupFundTransactions(String groupId) =>
      '/groups/$groupId/fund/transactions';
  static String groupLeave(String id) => '/groups/$id/leave';
  static String groupMemberRole(String groupId, String memberId) =>
      '/groups/$groupId/members/$memberId/role';

  // ─── Expenses ─────────────────────────────────────────────────────────────
  static const expenses = '/expenses';
  static const categories = '/categories';
  static String expenseById(String id) => '/expenses/$id';
  static String settlements(String groupId) => '/groups/$groupId/settlements';
  static String balances(String groupId) => '/groups/$groupId/balances';

  // ─── Itinerary ────────────────────────────────────────────────────────────
  static String itineraries(String groupId) => '/groups/$groupId/itineraries';
  static String itineraryById(String groupId, String id) =>
      '/groups/$groupId/itineraries/$id';

  // ─── Recommendations ──────────────────────────────────────────────────────
  static String recommendations(String groupId) =>
      '/groups/$groupId/recommendations';

  // ─── AI Chat ──────────────────────────────────────────────────────────────
  static const aiChatSessions = '/ai/sessions';
  static String aiChatMessages(String sessionId) =>
      '/ai/sessions/$sessionId/messages';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
