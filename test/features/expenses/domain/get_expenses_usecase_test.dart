import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:nexora_mobile/core/errors/failure.dart';
import 'package:nexora_mobile/features/expenses/domain/entities/expense_entity.dart';
import 'package:nexora_mobile/features/expenses/domain/repositories/expense_repository.dart';
import 'package:nexora_mobile/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:nexora_mobile/shared/enums/app_enums.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

final _mockExpenses = [
  ExpenseEntity(
    id: 'e1',
    groupId: 'g1',
    paidByUserId: 'u1',
    title: 'Dinner',
    amount: 500000,
    currency: 'VND',
    fundingSource: FundingSource.personal,
    category: 'FOOD',
    splitType: ExpenseSplitType.shares,
    expenseDate: DateTime(2025, 6, 1),
    splits: const [],
    createdAt: DateTime(2025, 6, 1),
  ),
];

void main() {
  late MockExpenseRepository repository;
  late GetExpensesUseCase useCase;

  setUp(() {
    repository = MockExpenseRepository();
    useCase = GetExpensesUseCase(repository);
  });

  group('GetExpensesUseCase', () {
    test('returns expenses list on success', () async {
      when(() => repository.getExpenses(
            groupId: any(named: 'groupId'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => Right(_mockExpenses));

      final result = await useCase(const GetExpensesParams(groupId: 'g1'));

      expect(result, Right(_mockExpenses));
      verify(() => repository.getExpenses(groupId: 'g1', page: 1, pageSize: 20))
          .called(1);
    });

    test('returns Failure on network error', () async {
      when(() => repository.getExpenses(
                groupId: any(named: 'groupId'),
                page: any(named: 'page'),
                pageSize: any(named: 'pageSize'),
              ))
          .thenAnswer(
              (_) async => const Left(NetworkFailure(message: 'No internet')));

      final result = await useCase(const GetExpensesParams(groupId: 'g1'));

      expect(result.isLeft(), isTrue);
    });

    test('passes pagination params correctly', () async {
      when(() => repository.getExpenses(
            groupId: any(named: 'groupId'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => const Right([]));

      await useCase(
          const GetExpensesParams(groupId: 'g1', page: 2, pageSize: 10));

      verify(() => repository.getExpenses(groupId: 'g1', page: 2, pageSize: 10))
          .called(1);
    });
  });
}
