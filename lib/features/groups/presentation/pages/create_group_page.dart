import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/create_group_usecase.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currencyController =
      TextEditingController(text: AppConstants.defaultCurrency);
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  bool _isFlexibleBudget = true;

  @override
  void dispose() {
    _nameController.dispose();
    _currencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    // For now, mapping 'Destination' to 'name' as per usecase
    context.read<GroupCubit>().createGroup(
          CreateGroupParams(
            name: _nameController.text.trim(),
            currency: _currencyController.text.trim().isEmpty
                ? 'USD'
                : _currencyController.text.trim(),
            description:
                'Start: ${_startDateController.text}, End: ${_endDateController.text}',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>(),
      child: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupCreated) {
            context.pop();
          }
          if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;
          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('New Adventure', style: AppTextStyles.headlineMedium),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.auto_awesome,
                        color: AppColors.onPrimaryContainer, size: 20),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover Image Placeholder
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_alt_outlined,
                                    color: AppColors.onSurfaceVariant,
                                    size: 32),
                              ),
                            ),
                            const SizedBox(height: 32),

                            AppTextField(
                              label: 'Destination',
                              hint: 'e.g. Tokyo, Japan',
                              controller: _nameController,
                            ),
                            const SizedBox(height: 24),

                            Text('Travel Dates',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    hint: 'Start Date',
                                    controller: _startDateController,
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppTextField(
                                    hint: 'End Date',
                                    controller: _endDateController,
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 20),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            AppTextField(
                              label: 'Currency',
                              hint: 'e.g. USD - US Dollar',
                              controller: _currencyController,
                              suffixIcon: const Icon(Icons.keyboard_arrow_down),
                            ),
                            const SizedBox(height: 24),

                            Text('Budget Type',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _BudgetChip(
                                    label: 'Fixed',
                                    isSelected: !_isFlexibleBudget,
                                    onTap: () => setState(
                                        () => _isFlexibleBudget = false),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _BudgetChip(
                                    label: 'Flexible',
                                    isSelected: _isFlexibleBudget,
                                    onTap: () => setState(
                                        () => _isFlexibleBudget = true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'CONTINUE',
                          isLoading: isLoading,
                          color: AppColors.onSurface,
                          onPressed: () => _submit(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BudgetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.outlineVariant,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color:
                isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
