import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

double _stringToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

@JsonSerializable(explicitToJson: true)
class ExpenseSplitModel {
  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amountOwed,
    required this.isSettled,
    this.shares,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSplitModelFromJson(json);

  final String id;
  @JsonKey(name: 'expenseId')
  final String expenseId;
  @JsonKey(name: 'userId')
  final String userId;
  @JsonKey(name: 'amount', fromJson: _stringToDouble)
  final double amountOwed;
  @JsonKey(name: 'isSettled', defaultValue: false)
  final bool isSettled;
  final int? shares;

  Map<String, dynamic> toJson() => _$ExpenseSplitModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.groupId,
    required this.paidByUserId,
    required this.title,
    required this.amount,
    required this.currency,
    required this.fundingSource,
    required this.categoryId,
    required this.expenseDate,
    required this.splits,
    required this.splitType,
    required this.createdAt,
    this.description,
    this.receiptUrl,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  final String id;
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'createdBy')
  final String paidByUserId;
  final String title;
  @JsonKey(fromJson: _stringToDouble)
  final double amount;
  final String currency;
  @JsonKey(name: 'fundingSource')
  final String fundingSource;
  @JsonKey(name: 'categoryId')
  final String categoryId;
  @JsonKey(name: 'date')
  final String expenseDate;
  @JsonKey(name: 'payers')
  final List<ExpenseSplitModel> splits;
  @JsonKey(name: 'splitType')
  final String splitType;
  @JsonKey(name: 'createdAt')
  final String createdAt;
  final String? description;
  @JsonKey(name: 'receiptUrl')
  final String? receiptUrl;

  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}
