// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseSplitModel _$ExpenseSplitModelFromJson(Map<String, dynamic> json) =>
    ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      userId: json['userId'] as String,
      amountOwed: toMinorUnitsFromJson(json['amount']),
      isSettled: json['isSettled'] as bool? ?? false,
      shares: (json['shares'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExpenseSplitModelToJson(ExpenseSplitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseId': instance.expenseId,
      'userId': instance.userId,
      'amount': instance.amountOwed,
      'isSettled': instance.isSettled,
      'shares': instance.shares,
    };

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      paidByUserId: json['createdBy'] as String,
      title: json['title'] as String,
      amount: toMinorUnitsFromJson(json['amount']),
      currency: json['currency'] as String,
      fundingSource: json['fundingSource'] as String,
      categoryId: json['categoryId'] as String,
      category: json['category'] == null
          ? null
          : CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      expenseDate: json['date'] as String,
      splits: (json['payers'] as List<dynamic>)
          .map((e) => ExpenseSplitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      splitType: json['splitType'] as String,
      createdAt: json['createdAt'] as String,
      description: json['description'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'createdBy': instance.paidByUserId,
      'title': instance.title,
      'amount': instance.amount,
      'currency': instance.currency,
      'fundingSource': instance.fundingSource,
      'categoryId': instance.categoryId,
      'category': instance.category?.toJson(),
      'date': instance.expenseDate,
      'payers': instance.splits.map((e) => e.toJson()).toList(),
      'splitType': instance.splitType,
      'createdAt': instance.createdAt,
      'description': instance.description,
      'receiptUrl': instance.receiptUrl,
    };
