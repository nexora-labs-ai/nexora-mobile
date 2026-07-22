import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../groups/domain/repositories/group_repository.dart';
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
    final settlementsResult = await _settlementRepository.getGlobalPendingSettlements();

    groupsResult.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (groups) {
        settlementsResult.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (settlements) {
            emit(state.copyWith(
              isLoading: false,
              groups: groups,
              pendingSettlements: settlements,
            ));
          },
        );
      },
    );
  }
}
