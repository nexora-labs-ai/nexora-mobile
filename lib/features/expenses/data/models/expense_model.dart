import 'package:json_annotation/json_annotation.dart';

import '../../../../core/logger/app_logger.dart';
import '../../../../core/utils/currency_utils.dart';
import 'category_model.dart';

part 'expense_model.g.dart';

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
  @JsonKey(name: 'amount', fromJson: toMinorUnitsFromJson)
  final int amountOwed;
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
    required this.createdBy,
    required this.title,
    required this.amount,
    required this.currency,
    required this.fundingSource,
    required this.categoryId,
    this.category,
    required this.expenseDate,
    required this.payers,
    required this.splits,
    required this.splitType,
    required this.createdAt,
    this.description,
    this.receiptUrl,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    AppLogger.debug('ExpenseModel.fromJson input: $json');
    final result = _$ExpenseModelFromJson(json);
    AppLogger.debug('ExpenseModel.fromJson output: ${result.toJson()}');
    return result;
  }

  final String id;
  @JsonKey(name: 'groupId')
  final String groupId;
  @JsonKey(name: 'createdBy')
  final String createdBy;
  final String title;
  @JsonKey(fromJson: toMinorUnitsFromJson)
  final int amount;
  final String currency;
  @JsonKey(name: 'fundingSource')
  final String fundingSource;
  @JsonKey(name: 'categoryId')
  final String categoryId;
  @JsonKey(name: 'category')
  final CategoryModel? category;
  @JsonKey(name: 'date')
  final String expenseDate;
  @JsonKey(name: 'payers')
  final List<ExpenseSplitModel> payers;
  @JsonKey(name: 'splits')
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
