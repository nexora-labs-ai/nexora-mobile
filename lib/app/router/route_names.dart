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
  static const notifications = '/notifications';
  static const profile = '/profile';

  // ─── Groups ────────────────────────────────────────────────────────────────
  static const groupDetail = '/groups/:groupId';
  static const createGroup = '/groups/create';
  static const inviteMember = '/groups/:groupId/invite';

  // ─── Expenses ──────────────────────────────────────────────────────────────
  static const expenses = '/groups/:groupId/expenses';
  static const createExpense = '/groups/:groupId/expenses/create';
  static const expenseDetail = '/groups/:groupId/expenses/:expenseId';

  // ─── Chat ──────────────────────────────────────────────────────────────────
  static const chat = '/groups/:groupId/chat';
  static const aiAssistant = '/ai-assistant';

  // ─── Settings ──────────────────────────────────────────────────────────────
  static const settings = '/settings';
}
