import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nexora_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:nexora_mobile/features/settlements/presentation/widgets/review_settlement_bottom_sheet.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/components/error_view.dart';
import '../../../../../shared/enums/app_enums.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/optimized_settlement_entity.dart';
import '../../domain/entities/settlement_entity.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/settle_up_bottom_sheet.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen(
      {super.key, required this.groupId, this.isTab = false});

  final String groupId;
  final bool isTab;

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  static final Map<String, Map<String, DateTime>> _globalRemindTimestamps = {};
  late final Map<String, DateTime> _remindTimestamps;
  int _selectedTabIndex = 0; // 0: To Pay, 1: To Receive, 2: History

  @override
  void initState() {
    super.initState();
    _remindTimestamps =
        _globalRemindTimestamps.putIfAbsent(widget.groupId, () => {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettlementBloc>(
          create: (context) =>
              sl<SettlementBloc>()..add(LoadSettlements(widget.groupId)),
        ),
        BlocProvider<GroupCubit>(
          create: (context) =>
              sl<GroupCubit>()..loadGroupDetail(widget.groupId),
        ),
      ],
      child: widget.isTab
          ? _buildAuthWrapper()
          : Scaffold(
              backgroundColor: AppColors.canvas,
              body: SafeArea(
                child: _buildAuthWrapper(),
              ),
            ),
    );
  }

  Widget _buildAuthWrapper() {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox();
        }
        final currentUserId = authState.user.id;

        return BlocBuilder<GroupCubit, GroupState>(
          builder: (context, groupState) {
            if (groupState is GroupLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (groupState is GroupFailureState) {
              return ErrorView(
                message: groupState.message,
                onRetry: () =>
                    context.read<GroupCubit>().loadGroupDetail(widget.groupId),
              );
            }

            if (groupState is GroupDetailLoaded) {
              return BlocConsumer<SettlementBloc, SettlementState>(
                listener: (context, state) {
                  if (state is SettlementActionFailure) {
                    final msg = state.message
                        .replaceAll('ValidationFailure(', '')
                        .replaceAll(', null, {})', '');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );
                  }
                },
                buildWhen: (previous, current) =>
                    current is! SettlementActionFailure,
                builder: (context, settlementState) {
                  if (settlementState is SettlementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (settlementState is SettlementError) {
                    return ErrorView(
                      message: settlementState.message,
                      onRetry: () => context
                          .read<SettlementBloc>()
                          .add(LoadSettlements(widget.groupId)),
                    );
                  }

                  if (settlementState is SettlementLoaded) {
                    return _buildContent(context, currentUserId,
                        groupState.group, groupState.members, settlementState);
                  }

                  return const SizedBox();
                },
              );
            }

            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    String currentUserId,
    GroupEntity group,
    List<GroupMemberEntity> members,
    SettlementLoaded settlementState,
  ) {
    final youOweList = settlementState.optimizedSettlements
        .where((s) => s.fromUserId == currentUserId)
        .toList();
    final owesYouList = settlementState.optimizedSettlements
        .where((s) => s.toUserId == currentUserId)
        .toList();

    int totalYouOwe = youOweList.fold<int>(0, (sum, item) => sum + item.amount);
    int totalOwesYou =
        owesYouList.fold<int>(0, (sum, item) => sum + item.amount);

    // Total raw settlements vs optimized for efficiency score
    int rawCount = settlementState.settlements.length;
    int optimizedCount = settlementState.optimizedSettlements.length;
    double efficiency = 0;
    if (rawCount > 0) {
      efficiency = ((rawCount - optimizedCount) / rawCount) * 100;
      if (efficiency < 0) efficiency = 0;
    } else if (optimizedCount == 0) {
      efficiency = 100; // if no debts, 100% efficient
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SettlementBloc>().add(LoadSettlements(widget.groupId));
        context.read<GroupCubit>().loadGroupDetail(widget.groupId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFF6F8F3), // Very light greenish background
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('TO RECEIVE',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5B6953), // Gray-green text
                                letterSpacing: 1.0)),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '+${_formatAmount(totalOwesYou, group.currency)}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color: Color(
                                          0xFF2E6342))), // Dark green text
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_outward,
                                  size: 18, color: Color(0xFF2E6342)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('TO PAY',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6B5854), // Gray-red text
                                letterSpacing: 1.0)),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '-${_formatAmount(totalYouOwe, group.currency)}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color:
                                          Color(0xFFB71C1C))), // Dark red text
                              const SizedBox(width: 4),
                              Transform.rotate(
                                angle: 3.14159 /
                                    2, // Rotate outward arrow to point bottom-right
                                child: const Icon(Icons.arrow_outward,
                                    size: 18, color: Color(0xFFB71C1C)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (rawCount > 1 && optimizedCount < rawCount) ...[
              _EfficiencyScoreCard(
                efficiencyPercentage: efficiency.toInt(),
                rawTransactions: rawCount,
                optimizedTransactions: optimizedCount,
              ),
              const SizedBox(height: 16),
            ],
            // Custom Segmented Control
            _buildCustomTabBar(),
            const SizedBox(height: 16),

            // Tab Content
            if (_selectedTabIndex == 0) ...[
              if (youOweList.isEmpty)
                _buildEmptyState('No active debts to pay.')
              else ...[
                _buildSectionTitle('Active Debts',
                    icon: Icons.call_made, iconColor: AppColors.error),
                const SizedBox(height: 16),
                ...youOweList.map((settlement) => _DebtListItem(
                      settlement: settlement,
                      isYouOwe: true,
                      member: _getMember(members, settlement.toUserId),
                      currency: group.currency,
                      groupId: group.id,
                      rawSettlements: settlementState.settlements,
                      currentUserId: currentUserId,
                      remindTimestamps: _remindTimestamps,
                      onRemind: (userId, time) {
                        setState(() {
                          _remindTimestamps[userId] = time;
                        });
                      },
                      onRemindExpired: (userId) {
                        setState(() {
                          _remindTimestamps.remove(userId);
                        });
                      },
                    )),
              ],
            ] else if (_selectedTabIndex == 1) ...[
              if (owesYouList.isEmpty)
                _buildEmptyState('No one owes you money right now.')
              else ...[
                _buildSectionTitle('Pending Collections',
                    icon: Icons.call_received, iconColor: AppColors.primary),
                const SizedBox(height: 16),
                ...owesYouList.map((settlement) => _DebtListItem(
                      settlement: settlement,
                      isYouOwe: false,
                      member: _getMember(members, settlement.fromUserId),
                      currency: group.currency,
                      groupId: group.id,
                      rawSettlements: settlementState.settlements,
                      currentUserId: currentUserId,
                      remindTimestamps: _remindTimestamps,
                      onRemind: (userId, time) {
                        setState(() {
                          _remindTimestamps[userId] = time;
                        });
                      },
                      onRemindExpired: (userId) {
                        setState(() {
                          _remindTimestamps.remove(userId);
                        });
                      },
                    )),
              ],
            ] else ...[
              // History Tab
              _buildHistoryTab(settlementState.settlements, members,
                  currentUserId, group.currency),
            ],
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.outline,
              ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton(0, 'To Pay'),
          _buildTabButton(1, 'To Receive'),
          _buildTabButton(2, 'History'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(List<SettlementEntity> settlements,
      List<GroupMemberEntity> members, String currentUserId, String currency) {
    final completedSettlements = settlements
        .where((s) => s.status == SettlementStatus.completed)
        .toList();

    if (completedSettlements.isEmpty) {
      return _buildEmptyState('No recent activity.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Activity'),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedSettlements.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.outlineVariant),
            itemBuilder: (context, index) {
              final settlement = completedSettlements[index];
              final isYouPayer = settlement.fromUserId == currentUserId;
              final otherUserId =
                  isYouPayer ? settlement.toUserId : settlement.fromUserId;
              final otherMember = _getMember(members, otherUserId);

              final amountFormatted =
                  _formatAmount(settlement.amount, currency);
              final dateFormatted =
                  DateFormat('MMM dd, yyyy').format(settlement.createdAt);

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F8E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isYouPayer
                                ? 'Paid ${otherMember.displayName}'
                                : '${otherMember.displayName} paid you',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatted,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      amountFormatted,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onSurfaceVariant, // Grayed out amount
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  GroupMemberEntity _getMember(List<GroupMemberEntity> members, String userId) {
    return members.firstWhere(
      (m) => m.userId == userId,
      orElse: () => GroupMemberEntity(
        id: '',
        groupId: '',
        userId: userId,
        role: GroupRole.member,
        joinedAt: DateTime.now(),
        displayName: 'Unknown',
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 24, color: iconColor ?? AppColors.onSurface),
          const SizedBox(width: 8),
        ],
        Text(title,
            style: AppTextStyles.headlineMedium
                .copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _EfficiencyScoreCard extends StatelessWidget {
  final int efficiencyPercentage;
  final int rawTransactions;
  final int optimizedTransactions;

  const _EfficiencyScoreCard({
    required this.efficiencyPercentage,
    required this.rawTransactions,
    required this.optimizedTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFAEEA66), // Bright green background from mockup
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efficiency Score',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF4C7B19), // Darker green text
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Optimized Settlement',
            style: AppTextStyles.titleMedium.copyWith(
              color: const Color(0xFF284D04),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$efficiencyPercentage%',
            style: AppTextStyles.displayLarge.copyWith(
              color: const Color(0xFF1E4000),
              fontWeight: FontWeight.w900,
              fontSize: 64,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nexora AI has reduced $rawTransactions transactions into $optimizedTransactions easy payments.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF35610F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtListItem extends StatelessWidget {
  final OptimizedSettlementEntity settlement;
  final bool isYouOwe;
  final GroupMemberEntity member;
  final String currency;
  final String groupId;
  final List<SettlementEntity> rawSettlements;
  final String currentUserId;
  final Map<String, DateTime> remindTimestamps;
  final Function(String, DateTime) onRemind;
  final Function(String) onRemindExpired;

  const _DebtListItem({
    required this.settlement,
    required this.isYouOwe,
    required this.member,
    required this.currency,
    required this.groupId,
    required this.rawSettlements,
    required this.currentUserId,
    required this.remindTimestamps,
    required this.onRemind,
    required this.onRemindExpired,
  });

  @override
  Widget build(BuildContext context) {
    // Find all pending transactions for this specific debt pair
    List<SettlementEntity> pendingSettlements = [];
    if (isYouOwe) {
      pendingSettlements = rawSettlements
          .where((s) =>
              s.fromUserId == currentUserId &&
              s.toUserId == member.userId &&
              s.status == SettlementStatus.pending)
          .toList();
    } else {
      pendingSettlements = rawSettlements
          .where((s) =>
              s.fromUserId == member.userId &&
              s.toUserId == currentUserId &&
              s.status == SettlementStatus.pending)
          .toList();
    }

    final initials = member.displayName.length >= 2
        ? member.displayName.substring(0, 2).toUpperCase()
        : (member.displayName.isNotEmpty
            ? member.displayName[0].toUpperCase()
            : '?');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        isYouOwe ? const Color(0xFFE8F5E9) : AppColors.primary,
                    child: Text(initials,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.displayName,
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        const Text('Group expenses balance',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(settlement.remainingAmount, currency),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isYouOwe
                                ? const Color(0xFFC62828)
                                : AppColors.primary),
                      ),
                      if (settlement.pendingAmount > 0) ...[
                        Text(
                          'left of ${_formatAmount(settlement.amount, currency)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.hourglass_empty,
                                size: 12, color: Colors.orange.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatAmount(settlement.pendingAmount, currency)} pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ],
              ),
              if (pendingSettlements.isNotEmpty ||
                  settlement.remainingAmount > 0) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    if (pendingSettlements.isNotEmpty)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: isYouOwe
                              ? _buildWaitingForApproval(
                                  context, pendingSettlements, member)
                              : _buildReviewButton(
                                  context, pendingSettlements, member),
                        ),
                      ),
                    if (pendingSettlements.isNotEmpty &&
                        settlement.remainingAmount > 0)
                      const SizedBox(width: 12),
                    if (settlement.remainingAmount > 0)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: isYouOwe
                              ? _buildPayButton(context, settlement, groupId)
                              : _buildRemindButton(context, settlement, groupId,
                                  remindTimestamps, onRemind, onRemindExpired),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingForApproval(BuildContext context,
      List<SettlementEntity> pendingSettlements, GroupMemberEntity member) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: context.read<SettlementBloc>(),
                  child: ReviewSettlementBottomSheet(
                    settlements: pendingSettlements,
                    memberName: member.displayName,
                    avatarUrl: member.avatarUrl,
                    isDebtorView: true,
                  ),
                ),
              );
            },
            icon: Icon(Icons.pending_actions,
                size: 16, color: Colors.orange.shade800),
            label: const Text('VIEW PENDING',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade800,
              elevation: 0,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.orange.shade200),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewButton(BuildContext context,
      List<SettlementEntity> pendingSettlements, GroupMemberEntity member) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: context.read<SettlementBloc>(),
            child: ReviewSettlementBottomSheet(
              settlements: pendingSettlements,
              memberName: member.displayName,
              avatarUrl: member.avatarUrl,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade500,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('REVIEW',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildPayButton(BuildContext context,
      OptimizedSettlementEntity settlement, String groupId) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return SettleUpBottomSheet(
              groupId: groupId,
              toUserId: settlement.toUserId,
              amount: settlement.remainingAmount,
              bloc: context.read<SettlementBloc>(),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9CCC65),
        foregroundColor: AppColors.ink,
        elevation: 0,
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('PAY NOW',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildRemindButton(
    BuildContext context,
    OptimizedSettlementEntity settlement,
    String groupId,
    Map<String, DateTime> remindTimestamps,
    Function onRemind,
    Function onRemindExpired,
  ) {
    if (remindTimestamps.containsKey(settlement.fromUserId)) {
      return RemindCountdownWidget(
        endTime: remindTimestamps[settlement.fromUserId]!,
        onTimerComplete: () {
          onRemindExpired(settlement.fromUserId);
        },
      );
    }

    return OutlinedButton(
      onPressed: () {
        context.read<SettlementBloc>().add(
              RemindSettlement(
                groupId: groupId,
                targetUserId: settlement.fromUserId,
              ),
            );
        onRemind(
          settlement.fromUserId,
          DateTime.now().add(const Duration(hours: 1)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder sent!')),
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('REMIND',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class RemindCountdownWidget extends StatefulWidget {
  final DateTime endTime;
  final VoidCallback onTimerComplete;

  const RemindCountdownWidget({
    super.key,
    required this.endTime,
    required this.onTimerComplete,
  });

  @override
  State<RemindCountdownWidget> createState() => _RemindCountdownWidgetState();
}

class _RemindCountdownWidgetState extends State<RemindCountdownWidget> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    if (now.isAfter(widget.endTime)) {
      _timer.cancel();
      widget.onTimerComplete();
    } else {
      setState(() {
        _timeLeft = widget.endTime.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DateTime.now().isAfter(widget.endTime)) return const SizedBox.shrink();

    final minutes = _timeLeft.inMinutes.toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined,
            size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$minutes:$seconds',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

String _formatAmount(int amount, String currency) {
  final currencySymbol =
      NumberFormat.simpleCurrency(name: currency).currencySymbol;
  return formatCurrency(amount / 100.0, symbol: currencySymbol);
}
