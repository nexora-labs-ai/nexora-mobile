import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import 'dashboard_state.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(
    this._groupRepository,
  ) : super(const DashboardState());

  final GroupRepository _groupRepository;

  Future<void> loadDashboardData() async {
    emit(state.copyWith(isLoading: true, error: null));

    final groupsResult = await _groupRepository.getGroups();

    groupsResult.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (groups) {
        emit(state.copyWith(
          isLoading: false,
          groups: groups,
          pendingSettlements: [], // Mock empty list for now since API doesn't exist
        ));
      },
    );
  }
}
