import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/create_expense_usecase.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class CreateExpensePage extends StatefulWidget {
  const CreateExpensePage({required this.groupId, super.key});

  final String groupId;

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final String _selectedCategory = 'FOOD';
  String _selectedCurrency = AppConstants.defaultCurrency;
  DateTime _expenseDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ExpenseCubit>();
    // TODO: inject currentUserId from AuthCubit
    const currentUserId = 'current_user_id';

    cubit.createExpense(
      CreateExpenseParams(
        groupId: widget.groupId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        currency: _selectedCurrency,
        paidByUserId: currentUserId,
        category: _selectedCategory,
        fundingSource: 'PERSONAL',
        expenseDate: _expenseDate,
        splits: const [], // TODO: collect splits from SplitFormWidget
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseCreated) context.pop();
        if (state is ExpenseFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          final isLoading = state is ExpenseCreating;
          return Scaffold(
            appBar: AppBar(title: const Text('Add Expense')),
            body: SingleChildScrollView(
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
                      validator: (v) =>
                          FormValidators.required(v, fieldName: 'Title'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Amount',
                            controller: _amountController,
                            hint: '0',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: FormValidators.positiveAmount,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          items: AppConstants.supportedCurrencies
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCurrency = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle:
                          Text(DateFormat('MMM dd, yyyy').format(_expenseDate)),
                      trailing: const Icon(Icons.calendar_today_outlined),
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
                      onPressed: isLoading ? null : () => _submit(context),
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
