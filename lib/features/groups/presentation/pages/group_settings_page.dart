import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/bindings/injection_container.dart';
import '../cubit/group_cubit.dart';
import '../cubit/group_state.dart';

class GroupSettingsPage extends StatefulWidget {
  const GroupSettingsPage({required this.groupId, super.key});

  final String groupId;

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _currency = 'USD';
  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final primaryColor = Theme.of(context).primaryColor;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (!context.mounted) return;
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Avatar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && context.mounted) {
        context
            .read<GroupCubit>()
            .uploadAvatar(widget.groupId, File(croppedFile.path));
      }
    }
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<GroupCubit>().updateGroup(
        widget.groupId,
        {
          'name': _nameController.text,
          'description': _descController.text,
          'currency': _currency,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GroupCubit>()..loadGroupDetail(widget.groupId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Group Settings')),
        body: BlocConsumer<GroupCubit, GroupState>(
          listener: (context, state) {
            if (state is GroupFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is GroupUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group updated successfully!')),
              );
            } else if (state is GroupAvatarUploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar uploaded successfully!')),
              );
            }
          },
          builder: (context, state) {
            if (state is GroupLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GroupDetailLoaded && !_isInit) {
              _nameController.text = state.group.name;
              _descController.text = state.group.description ?? '';
              _currency = state.group.currency;
              _isInit = true;
            }

            if (state is GroupDetailLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: state.group.avatarUrl != null
                              ? NetworkImage(state.group.avatarUrl!)
                              : null,
                          child: state.group.avatarUrl == null
                              ? const Icon(Icons.camera_alt, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _pickImage(context),
                        child: const Text('Change Avatar'),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items: ['USD', 'VND', 'EUR', 'JPY']
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _currency = v);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => _submit(context),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
