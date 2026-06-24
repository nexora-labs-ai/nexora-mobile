import 'package:injectable/injectable.dart';

import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/invite_member_usecase.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/leave_group_usecase.dart';
import '../../domain/usecases/kick_member_usecase.dart';
import '../../domain/usecases/update_member_role_usecase.dart';
import '../../domain/usecases/get_group_members_usecase.dart';
import 'group_state.dart';

@injectable
class GroupCubit extends BaseCubit<GroupState> {
  GroupCubit(
    this._getGroupsUseCase,
    this._getGroupDetailUseCase,
    this._createGroupUseCase,
    this._inviteMemberUseCase,
    this._leaveGroupUseCase,
    this._kickMemberUseCase,
    this._updateMemberRoleUseCase,
    this._getGroupMembersUseCase,
  ) : super(const GroupInitial());

  final GetGroupsUseCase _getGroupsUseCase;
  final GetGroupDetailUseCase _getGroupDetailUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final InviteMemberUseCase _inviteMemberUseCase;
  final LeaveGroupUseCase _leaveGroupUseCase;
  final KickMemberUseCase _kickMemberUseCase;
  final UpdateMemberRoleUseCase _updateMemberRoleUseCase;
  final GetGroupMembersUseCase _getGroupMembersUseCase;

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
    
    await groupResult.fold(
      (failure) async {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (group) async {
        final membersResult = await _getGroupMembersUseCase(groupId);
        
        membersResult.fold(
          (failure) {
            logFailure(failure);
            safeEmit(GroupFailureState(message: failure.message));
          },
          (members) => safeEmit(GroupDetailLoaded(group: group, members: members)),
        );
      },
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

  Future<void> leaveGroup(String groupId) async {
    safeEmit(const GroupLoading());

    final result = await _leaveGroupUseCase(groupId);

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (_) {
        safeEmit(const GroupLeft());
        loadGroups();
      },
    );
  }

  Future<void> kickMember({required String groupId, required String userId}) async {
    safeEmit(const GroupLoading());

    final result = await _kickMemberUseCase(KickMemberParams(groupId: groupId, userId: userId));

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (_) => loadGroupDetail(groupId),
    );
  }

  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required GroupRole role,
  }) async {
    safeEmit(const GroupLoading());

    final result = await _updateMemberRoleUseCase(
      UpdateMemberRoleParams(groupId: groupId, userId: userId, role: role),
    );

    result.fold(
      (failure) {
        logFailure(failure);
        safeEmit(GroupFailureState(message: failure.message));
      },
      (_) => loadGroupDetail(groupId),
    );
  }
}
