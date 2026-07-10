import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bindings/injection_container.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../expenses/presentation/widgets/group_balance_summary_widget.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../bloc/settlement_bloc.dart';
import '../widgets/optimized_debts_view.dart';
import '../widgets/settlement_history_view.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<SettlementBloc>()..add(LoadSettlements(widget.groupId)),
        ),
        BlocProvider(
          create: (context) =>
              sl<GroupCubit>()..loadGroupDetail(widget.groupId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settlements'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Settle Up'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: BlocBuilder<GroupCubit, GroupState>(
          builder: (context, groupState) {
            Map<String, String> userNames = {};
            String currentUserId = '';
            final authState = sl<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              currentUserId = authState.user.id;
            }
            if (groupState is GroupDetailLoaded) {
              for (var member in groupState.members) {
                userNames[member.userId] = member.displayName;
              }
            }

            return BlocBuilder<SettlementBloc, SettlementState>(
              builder: (context, state) {
                if (state is SettlementLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SettlementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                      ],
                    ),
                  );
                } else if (state is SettlementLoaded) {
                  return Column(
                    children: [
                      if (state.balances.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: GroupBalanceSummaryWidget(
                            balances: state.balances,
                            members: groupState is GroupDetailLoaded
                                ? groupState.members
                                : [],
                            currency: groupState is GroupDetailLoaded
                                ? groupState.group.currency
                                : 'USD',
                          ),
                        ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            OptimizedDebtsView(
                              state: state,
                              userNames: userNames,
                              currentUserId: currentUserId,
                              groupId: widget.groupId,
                            ),
                            SettlementHistoryView(
                              state: state,
                              userNames: userNames,
                              currentUserId: currentUserId,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
