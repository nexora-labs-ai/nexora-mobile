import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../settlements/domain/entities/settlement_entity.dart';

part 'dashboard_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(true) bool isLoading,
    @Default([]) List<GroupEntity> groups,
    @Default([]) List<SettlementEntity> pendingSettlements,
    String? error,
  }) = _DashboardState;
}
