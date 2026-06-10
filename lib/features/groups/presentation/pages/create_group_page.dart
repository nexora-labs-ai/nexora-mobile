import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/validators/form_validators.dart';
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
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  String _eventType = 'TRIP';
  String _currency = AppConstants.defaultCurrency;
  DateTime? _startDate;
  DateTime? _endDate;

  static const _eventTypes = ['TRIP', 'WORKSHOP', 'PARTY', 'HACKATHON', 'OTHER'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<GroupCubit>().createGroup(
          CreateGroupParams(
            name: _nameController.text.trim(),
            eventType: _eventType,
            currency: _currency,
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            targetBudget: _budgetController.text.isNotEmpty
                ? double.tryParse(_budgetController.text)
                : null,
            eventDateStart: _startDate,
            eventDateEnd: _endDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>(),
      child: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupCreated) context.pop();
          if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('Create Group')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Group Name',
                      controller: _nameController,
                      hint: 'Da Nang Trip 2025',
                      validator: (v) => FormValidators.minLength(v, 3, fieldName: 'Group name'),
                    ),
                    const SizedBox(height: 16),
                    Text('Event Type', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _eventTypes.map((type) {
                        return ChoiceChip(
                          label: Text(type),
                          selected: _eventType == type,
                          onSelected: (_) => setState(() => _eventType = type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Description (optional)',
                      controller: _descriptionController,
                      hint: 'Beach trip with the gang',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Target Budget (optional)',
                            controller: _budgetController,
                            hint: '5000000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _currency,
                          items: AppConstants.supportedCurrencies
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Create Group',
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
