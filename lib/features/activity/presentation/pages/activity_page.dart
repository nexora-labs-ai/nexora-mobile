import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bindings/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_filter_dropdown.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late final ActivityCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ActivityCubit>()..init();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Activity'),
          backgroundColor: AppColors.canvas,
          elevation: 0,
        ),
        body: Column(
          children: [
            ActivityFilterDropdown(
              selectedGroupId: _selectedGroupId,
              onChanged: (groupId) {
                setState(() {
                  _selectedGroupId = groupId;
                });
                _cubit.fetchActivities(groupId: groupId);
              },
            ),
            Expanded(
              child: BlocBuilder<ActivityCubit, ActivityState>(
                builder: (context, state) {
                  if (state is ActivityLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is ActivityFailure) {
                    return Center(
                      child: Text(
                        'Failed to load activities: ${state.message}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  if (state is ActivityLoaded) {
                    if (state.activities.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        await _cubit.fetchActivities(
                          groupId: _selectedGroupId,
                          isRefresh: true,
                        );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.activities.length +
                            (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= state.activities.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }

                          return ActivityCard(
                            activity: state.activities[index],
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_activity_outlined,
            size: 64,
            color: AppColors.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No recent activity',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activities from your groups will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
