import 'dart:io';

import 'package:dartz/dartz.dart' as dartz;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../expenses/domain/entities/group_balance_entity.dart';
import '../../../expenses/domain/usecases/get_group_balance_usecase.dart';
import '../../domain/entities/optimized_settlement_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../../domain/repositories/settlement_repository.dart';

// --- Events ---
abstract class SettlementEvent extends Equatable {
  const SettlementEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettlements extends SettlementEvent {
  final String groupId;
  const LoadSettlements(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class RequestSettlement extends SettlementEvent {
  final String groupId;
  final String toUserId;
  final int amount;
  final String currency;
  final String? note;
  final File? evidenceFile;

  const RequestSettlement({
    required this.groupId,
    required this.toUserId,
    required this.amount,
    required this.currency,
    this.note,
    this.evidenceFile,
  });

  @override
  List<Object?> get props =>
      [groupId, toUserId, amount, currency, note, evidenceFile];
}

class CompleteSettlement extends SettlementEvent {
  final String settlementId;
  const CompleteSettlement(this.settlementId);
  @override
  List<Object?> get props => [settlementId];
}

class CancelSettlement extends SettlementEvent {
  final String settlementId;
  const CancelSettlement(this.settlementId);
  @override
  List<Object?> get props => [settlementId];
}

// --- States ---
abstract class SettlementState extends Equatable {
  const SettlementState();
  @override
  List<Object?> get props => [];
}

class SettlementInitial extends SettlementState {}

class SettlementLoading extends SettlementState {}

class SettlementLoaded extends SettlementState {
  final List<SettlementEntity> settlements;
  final List<OptimizedSettlementEntity> optimizedSettlements;
  final List<GroupBalanceEntity> balances;

  const SettlementLoaded({
    required this.settlements,
    required this.optimizedSettlements,
    required this.balances,
  });

  @override
  List<Object?> get props => [settlements, optimizedSettlements, balances];
}

class SettlementError extends SettlementState {
  final String message;
  const SettlementError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
@injectable
class SettlementBloc extends Bloc<SettlementEvent, SettlementState> {
  final SettlementRepository _repository;
  final GetGroupBalanceUseCase _getGroupBalanceUseCase;

  SettlementBloc(this._repository, this._getGroupBalanceUseCase)
      : super(SettlementInitial()) {
    on<LoadSettlements>(_onLoadSettlements);
    on<RequestSettlement>(_onRequestSettlement);
    on<CompleteSettlement>(_onCompleteSettlement);
    on<CancelSettlement>(_onCancelSettlement);
  }

  Future<void> _onLoadSettlements(
      LoadSettlements event, Emitter<SettlementState> emit) async {
    emit(SettlementLoading());

    final results = await Future.wait([
      _repository.getGroupSettlements(event.groupId),
      _repository.getOptimizedSettlements(event.groupId),
      _getGroupBalanceUseCase(GetGroupBalanceParams(groupId: event.groupId)),
    ]);

    final settlementsResult =
        results[0] as dartz.Either<dynamic, List<SettlementEntity>>;
    final optimizedResult =
        results[1] as dartz.Either<dynamic, List<OptimizedSettlementEntity>>;
    final balanceResult =
        results[2] as dartz.Either<dynamic, List<GroupBalanceEntity>>;

    settlementsResult.fold(
      (failure) => emit(SettlementError(failure.toString())),
      (settlements) {
        optimizedResult.fold(
          (failure) => emit(SettlementError(failure.toString())),
          (optimized) {
            final balances =
                balanceResult.fold((l) => <GroupBalanceEntity>[], (r) => r);
            emit(SettlementLoaded(
              settlements: settlements,
              optimizedSettlements: optimized,
              balances: balances,
            ));
          },
        );
      },
    );
  }

  Future<void> _onRequestSettlement(
      RequestSettlement event, Emitter<SettlementState> emit) async {
    final result = await _repository.requestSettlement(
      groupId: event.groupId,
      toUserId: event.toUserId,
      amount: event.amount,
      currency: event.currency,
      note: event.note,
    );

    await result.fold(
      (failure) async => emit(SettlementError(failure.toString())),
      (settlement) async {
        if (event.evidenceFile != null) {
          final uploadResult = await _repository.uploadEvidence(
              settlement.id, event.evidenceFile!);
          uploadResult.fold(
            (f) => emit(SettlementError(f.toString())),
            (_) => add(LoadSettlements(event.groupId)),
          );
        } else {
          add(LoadSettlements(event.groupId));
        }
      },
    );
  }

  Future<void> _onCompleteSettlement(
      CompleteSettlement event, Emitter<SettlementState> emit) async {
    final result = await _repository.completeSettlement(event.settlementId);
    result.fold(
      (failure) => emit(SettlementError(failure.toString())),
      (SettlementEntity settlement) => add(LoadSettlements(settlement.groupId)),
    );
  }

  Future<void> _onCancelSettlement(
      CancelSettlement event, Emitter<SettlementState> emit) async {
    final result = await _repository.cancelSettlement(event.settlementId);
    result.fold(
      (failure) => emit(SettlementError(failure.toString())),
      (SettlementEntity settlement) => add(LoadSettlements(settlement.groupId)),
    );
  }
}
