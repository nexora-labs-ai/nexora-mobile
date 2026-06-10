abstract final class AppConstants {
  // ─── Pagination ───────────────────────────────────────────────────────────
  static const defaultPageSize = 20;
  static const firstPage = 1;

  // ─── Cache TTL ────────────────────────────────────────────────────────────
  static const cacheTtlShort = Duration(minutes: 5);
  static const cacheTtlMedium = Duration(minutes: 30);
  static const cacheTtlLong = Duration(hours: 24);

  // ─── Hive Box Names ───────────────────────────────────────────────────────
  static const hiveGroupsBox = 'nexora_groups';
  static const hiveExpensesBox = 'nexora_expenses';
  static const hiveMessagesBox = 'nexora_messages';

  // ─── Supported Currencies ─────────────────────────────────────────────────
  static const supportedCurrencies = ['VND', 'USD', 'EUR', 'SGD', 'THB'];
  static const defaultCurrency = 'VND';

  // ─── Max Constraints ──────────────────────────────────────────────────────
  static const maxGroupMembers = 50;
  static const maxGroupNameLength = 100;
  static const maxExpenseDescriptionLength = 500;
  static const maxChatMessageLength = 2000;

  // ─── Socket Event Names ───────────────────────────────────────────────────
  static const socketEventExpenseCreated = 'expense:created';
  static const socketEventExpenseUpdated = 'expense:updated';
  static const socketEventExpenseDeleted = 'expense:deleted';
  static const socketEventMessageReceived = 'chat:message';
  static const socketEventMemberJoined = 'group:member_joined';
  static const socketEventMemberLeft = 'group:member_left';
  static const socketEventBalanceUpdated = 'balance:updated';
}
