import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/validators/form_validators.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<GroupCubit>().inviteMember(
          groupId: widget.groupId,
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>(),
      child: BlocConsumer<GroupCubit, GroupState>(
        listener: (context, state) {
          if (state is GroupMemberInvited) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invitation sent successfully'), backgroundColor: AppColors.success),
            );
            context.pop();
          }
          if (state is GroupFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GroupLoading;
          return Scaffold(
            appBar: AppBar(title: const Text('Invite Member')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite someone to join this group.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      hint: 'user@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: FormValidators.email,
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Send Invitation',
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
