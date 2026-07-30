import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../settlements/domain/entities/settlement_entity.dart';
import '../../../settlements/domain/repositories/settlement_repository.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._groupRepository,
    this._settlementRepository,
  ) : super(const DashboardState());

  final GroupRepository _groupRepository;
  final SettlementRepository _settlementRepository;

  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, error: null));

    final groupsResult = await _groupRepository.getGroups();

    groupsResult.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (groups) async {
        final List<SettlementEntity> allPending = [];
        for (final group in groups) {
          final res =
              await _settlementRepository.getOptimizedSettlements(group.id);
          res.fold(
            (l) => null,
            (optimized) {
              for (final opt in optimized) {
                allPending.add(SettlementEntity(
                  id: '${group.id}-${opt.fromUserId}-${opt.toUserId}',
                  groupId: group.id,
                  fromUserId: opt.fromUserId,
                  toUserId: opt.toUserId,
                  amount: opt.amount,
                  currency: group.currency,
                  status: SettlementStatus.pending,
                  createdAt: DateTime.now(),
                ));
              }
            },
          );
        }

        emit(state.copyWith(
          isLoading: false,
          groups: groups,
          pendingSettlements: allPending,
        ));
      },
    );
  }
}
