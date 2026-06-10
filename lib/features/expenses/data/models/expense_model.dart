import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseSplitModel {
  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amountOwed,
    required this.isSettled,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSplitModelFromJson(json);

  final String id;
  @JsonKey(name: 'expense_id')
  final String expenseId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'amount_owed')
  final double amountOwed;
  @JsonKey(name: 'is_settled')
  final bool isSettled;

  Map<String, dynamic> toJson() => _$ExpenseSplitModelToJson(this);
}

@JsonSerializable()
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.fundingSource,
    required this.category,
    required this.expenseDate,
    required this.splits,
    required this.createdAt,
    this.description,
    this.receiptUrl,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  final String id;
  @JsonKey(name: 'group_id')
  final String groupId;
  @JsonKey(name: 'paid_by_user_id')
  final String paidByUserId;
  final String title;
  final double amount;
  final String currency;
  @JsonKey(name: 'funding_source')
  final String fundingSource;
  final String category;
  @JsonKey(name: 'expense_date')
  final String expenseDate;
  final List<ExpenseSplitModel> splits;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final String? description;
  @JsonKey(name: 'receipt_url')
  final String? receiptUrl;

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}
