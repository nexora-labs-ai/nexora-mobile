import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/invite_member_usecase.dart';
import 'group_state.dart';

@injectable
class GroupCubit extends BaseCubit<GroupState> {
  GroupCubit(
    this._getGroupsUseCase,
    this._getGroupDetailUseCase,
    this._createGroupUseCase,
    this._inviteMemberUseCase,
  ) : super(const GroupInitial());

  final GetGroupsUseCase _getGroupsUseCase;
  final GetGroupDetailUseCase _getGroupDetailUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final InviteMemberUseCase _inviteMemberUseCase;

  Future<void> loadGroups() async {
    safeEmit(const GroupLoading());

    final result = await _getGroupsUseCase(const NoParams());

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (groups) => safeEmit(GroupListLoaded(groups: groups)),
    );
  }

  Future<void> loadGroupDetail(String groupId) async {
    safeEmit(const GroupLoading());

    final groupResult = await _getGroupDetailUseCase(groupId);

    groupResult.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (group) => safeEmit(
        GroupDetailLoaded(group: group, members: const []),
      ),
    );
  }

  Future<void> createGroup(CreateGroupParams params) async {
    safeEmit(const GroupLoading());

    final result = await _createGroupUseCase(params);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (group) {
        safeEmit(GroupCreated(group: group));
        loadGroups();
      },
    );
  }

  Future<void> inviteMember({required String groupId, required String email}) async {
    safeEmit(const GroupLoading());

    final result = await _inviteMemberUseCase(InviteMemberParams(groupId: groupId, email: email));

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (_) => safeEmit(const GroupMemberInvited()),
    );
  }
}
