import 'package:json_annotation/json_annotation.dart';

enum LoadingStatus { initial, loading, success, failure }

enum ExpenseSplitType { exact, shares }

enum ExpenseCategory {
  food,
  transport,
  accommodation,
  entertainment,
  shopping,
  health,
  other
}

enum GroupRole { owner, member }

enum GroupEventType { trip, workshop, party, hackathon, other }

enum FundingSource { groupFund, personal }

enum MessageRole { user, assistant }

enum VoteType { up, down }

enum SettlementStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled
}

extension ExpenseSplitTypeExt on ExpenseSplitType {
  String toApi() => name.toUpperCase();
}

extension FundingSourceExt on FundingSource {
  String toApi() {
    switch (this) {
      case FundingSource.groupFund:
        return 'GROUP_FUND';
      case FundingSource.personal:
        return 'PERSONAL';
    }
  }
}
