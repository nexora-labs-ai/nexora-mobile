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
  static String groupFundContribute(String groupId) =>
      '/groups/$groupId/fund/contribute';
  static String groupFundWithdraw(String groupId) =>
      '/groups/$groupId/fund/withdraw';
  static String groupLeave(String id) => '/groups/$id/leave';
  static String groupMemberRole(String groupId, String memberId) =>
      '/groups/$groupId/members/$memberId/role';
  static String groupMessages(String id) => '/groups/$id/messages';

  // ─── Expenses ─────────────────────────────────────────────────────────────
  static const expenses = '/expenses';
  static const categories = '/categories';
  static String expenseById(String id) => '/expenses/$id';
  static const settlements = '/settlements';
  static const optimizedSettlements = '/settlements/optimized';
  static const pendingSettlements = '/settlements/pending';
  static String completeSettlement(String id) => '/settlements/$id/complete';
  static String cancelSettlement(String id) => '/settlements/$id/cancel';
  static const remindSettlement = '/settlements/remind';
  static String uploadSettlementEvidence(String id) =>
      '/settlements/$id/evidence';
  static const uploadReceipt = '/expenses/upload-receipt';
  static String expenseBalance(String groupId) =>
      '/expenses/group/$groupId/balance';

  // ─── Itinerary ────────────────────────────────────────────────────────────
  static String itineraryByGroup(String groupId) =>
      '/itinerary/groups/$groupId';
  static String itineraryGenerateByGroup(String groupId) =>
      '/itinerary/groups/$groupId/generate';
  static String itineraryPublish(String id) => '/itinerary/$id/publish';
  static String itineraryItems(String id) => '/itinerary/$id/items';
  static String itineraryItemById(String itineraryId, String itemId) =>
      '/itinerary/$itineraryId/items/$itemId';
  static String itineraryAiEdit(String id) => '/itinerary/$id/ai-edit';
  static String itineraryItemAiEdit(String itineraryId, String itemId) =>
      '/itinerary/$itineraryId/items/$itemId/ai-edit';

  // ─── Recommendations ──────────────────────────────────────────────────────
  static String recommendations(String groupId) =>
      '/groups/$groupId/recommendations';

  // ─── AI Chat ──────────────────────────────────────────────────────────────
  static const aiChatSessions = '/ai/sessions';
  static String aiChatMessages(String sessionId) =>
      '/ai/sessions/$sessionId/messages';

  // ─── Notifications ────────────────────────────────────────────────────────
  static const notifications = '/notifications';
  static const deviceToken = '/notifications/device-token';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
