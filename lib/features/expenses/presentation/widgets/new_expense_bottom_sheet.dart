import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/base/base_usecase.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class NewExpenseBottomSheet extends StatefulWidget {
  const NewExpenseBottomSheet({required this.groupId, super.key});

  final String groupId;

  static Future<void> show(BuildContext context, String groupId) {
    final expenseCubit = context.read<ExpenseCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BlocProvider.value(
          value: expenseCubit,
          child: NewExpenseBottomSheet(groupId: groupId),
        ),
      ),
    );
  }

  @override
  State<NewExpenseBottomSheet> createState() => _NewExpenseBottomSheetState();
}

class _NewExpenseBottomSheetState extends State<NewExpenseBottomSheet> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  List<CategoryEntity> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final usecase = sl<GetCategoriesUseCase>();
    final result = await usecase(const NoParams());

    if (mounted) {
      setState(() {
        _isLoadingCategories = false;
        result.fold(
          (l) => null,
          (r) {
            _categories = r;
            if (_categories.isNotEmpty) {
              _selectedCategory = _categories.first.id;
            }
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_amountController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final amountStr = _amountController.text.replaceAll(',', '');
    final amountDouble = double.tryParse(amountStr) ?? 0.0;
    final amountMinor = (amountDouble * 100).round(); // Assuming USD scale 2

    if (amountMinor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    // Create the expense (simplifying with default splits for "Quick Add")
    context.read<ExpenseCubit>().createExpense(CreateExpenseParams(
          groupId: widget.groupId,
          title: _titleController.text.trim(),
          amount: amountMinor,
          currency: 'USD',
          paidByUserId: userId,
          categoryId: _selectedCategory!,
          fundingSource: 'PERSONAL', // or GROUP_FUND
          expenseDate: DateTime.now(),
          splitType: 'EQUAL',
          splits: const [], // The backend will split equally among all members if EQUAL is passed
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseCreated) {
            Navigator.pop(context); // Close bottom sheet
          } else if (state is ExpenseFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ExpenseCreating;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text('Quick Expense',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // Amount Field (Large)
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.primary),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.primary),
                  hintText: '0.00',
                  hintStyle: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.outlineVariant),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              AppTextField(
                controller: _titleController,
                hint: 'What was this for?',
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 16),

              // Category Selector
              if (_isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (_categories.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category.id;
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category.id);
                          }
                        },
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 32),

              AppButton(
                label: 'Add Expense',
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}
