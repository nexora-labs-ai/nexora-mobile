import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/currency_utils.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../groups/domain/entities/group_entity.dart';
import '../../../groups/presentation/cubit/group_cubit.dart';
import '../../../groups/presentation/cubit/group_state.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../widgets/expense_split_widget.dart';

class CreateExpensePage extends StatelessWidget {
  const CreateExpensePage({required this.groupId, this.expenseId, super.key});

  final String groupId;
  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = sl<ExpenseCubit>()..loadCategories();
            if (expenseId != null) {
              cubit.loadExpenseDetail(groupId: groupId, expenseId: expenseId!);
            }
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => sl<GroupCubit>()..loadGroupDetail(groupId),
        ),
      ],
      child: _CreateExpensePageContent(groupId: groupId, expenseId: expenseId),
    );
  }
}

class _CreateExpensePageContent extends StatefulWidget {
  const _CreateExpensePageContent({required this.groupId, this.expenseId});

  final String groupId;
  final String? expenseId;

  @override
  State<_CreateExpensePageContent> createState() =>
      _CreateExpensePageContentState();
}

class _CreateExpensePageContentState extends State<_CreateExpensePageContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String _selectedCurrency = AppConstants.defaultCurrency;
  String _selectedSplitType = 'SHARES';
  String _selectedFundingSource = 'PERSONAL';
  DateTime _expenseDate = DateTime.now();
  List<Map<String, dynamic>> _splits = [];
  List<CategoryEntity> _categories = [];
  List<GroupMemberEntity> _members = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }
    final currentUserId = authState.user.id;

    final cubit = context.read<ExpenseCubit>();

    if (widget.expenseId != null) {
      cubit.updateExpense(
        UpdateExpenseParams(
          groupId: widget.groupId,
          expenseId: widget.expenseId!,
          fields: {
            'title': _titleController.text.trim(),
            'amount': stringToMinorUnits(_amountController.text),
            'currency': _selectedCurrency,
            'categoryId': _selectedCategory ?? '',
            'date': _expenseDate.toUtc().toIso8601String(),
            'fundingSource': _selectedFundingSource,
            'splitType': _selectedSplitType,
            'splits': _splits,
            'description': _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          },
        ),
      );
    } else {
      cubit.createExpense(
        CreateExpenseParams(
          groupId: widget.groupId,
          title: _titleController.text.trim(),
          amount: stringToMinorUnits(_amountController.text),
          currency: _selectedCurrency,
          paidByUserId: currentUserId,
          categoryId: _selectedCategory ?? '',
          fundingSource: _selectedFundingSource,
          expenseDate: _expenseDate,
          splitType: _selectedSplitType,
          splits: _splits,
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated || state is ExpenseUpdated) {
          context.pop(true);
        }
        if (state is ExpenseFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
        if (state is CategoriesLoaded) {
          setState(() {
            _categories = state.categories;
            if (_categories.isNotEmpty && _selectedCategory == null) {
              _selectedCategory = _categories.first.id;
            }
          });
        }
        if (state is ExpenseDetailLoaded) {
          final expense = state.expense;
          setState(() {
            _titleController.text = expense.title;
            _amountController.text = formatMinorUnits(expense.amount);
            _descriptionController.text = expense.description ?? '';
            _selectedCategory = expense.category;
            _selectedCurrency = expense.currency;
            _selectedFundingSource = expense.fundingSource.name == 'groupFund'
                ? 'GROUP_FUND'
                : 'PERSONAL';
            _selectedSplitType = expense.splitType.name.toUpperCase();
            _expenseDate = expense.expenseDate;
            _splits = expense.splits
                .map((s) => {
                      'userId': s.userId,
                      'amount': s.amountOwed,
                      'shares': s.shares
                    })
                .toList();
          });
        }
      },
      child: BlocListener<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupDetailLoaded) {
            setState(() {
              _members = state.members;
              if (widget.expenseId == null) {
                _selectedCurrency = state.group.currency;
              }
            });
          }
        },
        child: BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, state) {
            final isLoading = state is ExpenseCreating ||
                state is ExpenseUpdating ||
                state is CategoriesLoading ||
                state is ExpenseLoading;
            return Scaffold(
              appBar: AppBar(
                  title: Text(widget.expenseId == null
                      ? 'Add Expense'
                      : 'Edit Expense')),
              body: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextField(
                              label: 'Title',
                              controller: _titleController,
                              hint: 'Dinner at Bún Bò Huế',
                              validator: (v) => FormValidators.required(v,
                                  fieldName: 'Title'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Amount',
                                    controller: _amountController,
                                    hint: '0',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: FormValidators.positiveAmount,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                DropdownButton<String>(
                                  value: _selectedCurrency,
                                  items: AppConstants.supportedCurrencies
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged:
                                      null, // Disabled to lock it to group currency
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Date'),
                              subtitle: Text(DateFormat('MMM dd, yyyy')
                                  .format(_expenseDate)),
                              trailing:
                                  const Icon(Icons.calendar_today_outlined),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _expenseDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _expenseDate = picked);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_categories.isNotEmpty)
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                    labelText: 'Category'),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Row(
                                      children: [
                                        Text(c.icon),
                                        const SizedBox(width: 8),
                                        Text(c.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedCategory = v),
                              ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSplitType,
                              decoration: const InputDecoration(
                                  labelText: 'Split Type'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'SHARES', child: Text('By Shares')),
                                DropdownMenuItem(
                                    value: 'EXACT',
                                    child: Text('Exact Amount')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedSplitType = v!),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedFundingSource,
                              decoration: const InputDecoration(
                                  labelText: 'Funding Source'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'PERSONAL', child: Text('Personal')),
                                DropdownMenuItem(
                                    value: 'GROUP_FUND',
                                    child: Text('Group Fund')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedFundingSource = v!),
                            ),
                            const SizedBox(height: 16),
                            if (_members.isNotEmpty)
                              ExpenseSplitWidget(
                                splitType: _selectedSplitType,
                                members: _members,
                                onSplitsChanged: (splits) {
                                  setState(() {
                                    _splits = splits;
                                  });
                                },
                              )
                            else
                              const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Description (optional)',
                              controller: _descriptionController,
                              hint: 'Notes about this expense',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              label: 'Save Expense',
                              isLoading: isLoading,
                              onPressed:
                                  isLoading ? null : () => _submit(context),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
