abstract final class RouteNames {
  // ─── Root ──────────────────────────────────────────────────────────────────
  static const splash = '/';

  // ─── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // ─── Shell / Bottom Nav ────────────────────────────────────────────────────
  static const dashboard = '/dashboard';
  static const groups = '/groups';
  static const activity = '/activity';
  static const notifications = '/notifications';
  static const profile = '/profile';

  // ─── Groups ────────────────────────────────────────────────────────────────
  static const groupDetail = '/groups/:groupId';
  static const createGroup = '/groups/create';
  static const inviteMember = '/groups/:groupId/invite';

  // ─── Expenses ──────────────────────────────────────────────────────────────
  static const expenses = '/expenses';
  static const createExpense = '/expenses/create';
  static const expenseDetail = '/expenses/:expenseId';
  static const settlements = '/settlements';

  // ─── Itinerary ─────────────────────────────────────────────────────────────
  static const itinerary = '/groups/:groupId/itinerary';
  static const itineraryDetail = '/groups/:groupId/itinerary/:itineraryId';

  // ─── Chat ──────────────────────────────────────────────────────────────────
  static const chat = '/groups/:groupId/chat';
  static const aiAssistant = '/ai-assistant';

  // ─── Settings ──────────────────────────────────────────────────────────────
  static const settings = '/settings';
}
