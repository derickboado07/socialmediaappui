import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  String _gender = '';
  DateTime? _selectedDob;
  String _avatarPath = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser.value;
    if (user != null) {
      _nameCtrl.text = user.name;
      _bioCtrl.text = user.bio;
      _phoneCtrl.text = user.phone;
      _gender = user.gender;
      if (user.dob != null) {
        _dobCtrl.text = user.dob!;
        try {
          _selectedDob = DateTime.parse(user.dob!);
        } catch (_) {}
      }
      _avatarPath = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = AuthService.instance.currentUser.value;
    if (user == null) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await AuthService.instance.updateProfile(
      email: user.email,
      name: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      dob: _selectedDob != null
          ? _selectedDob!.toIso8601String().split('T').first
          : null,
      avatarPath: _avatarPath,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFE0E0E0),
                    child: _avatarPath.isEmpty
                        ? Text(
                            _nameCtrl.text.isNotEmpty
                                ? _nameCtrl.text[0].toUpperCase()
                                : '?',
                          )
                        : ClipOval(
                            child: _avatarPath.startsWith('http')
                                ? Image.network(
                                    _avatarPath,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_avatarPath),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final choice = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) {
                          return SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.photo_camera),
                                  title: const Text('Take photo'),
                                  onTap: () => Navigator.pop(context, 'camera'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('Choose from gallery'),
                                  onTap: () =>
                                      Navigator.pop(context, 'gallery'),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.close),
                                  title: const Text('Cancel'),
                                  onTap: () => Navigator.pop(context, null),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (choice == null) return;
                      final source = choice == 'camera'
                          ? ImageSource.camera
                          : ImageSource.gallery;
                      final XFile? picked = await ImagePicker().pickImage(
                        source: source,
                        maxWidth: 1200,
                        maxHeight: 1200,
                        imageQuality: 85,
                      );
                      if (picked == null) return;
                      setState(() => _avatarPath = picked.path);
                    },
                    child: const Text('Change Avatar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cellphone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? ''),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date of birth'),
                onTap: () async {
                  final now = DateTime.now();
                  final initial =
                      _selectedDob ??
                      DateTime(now.year - 18, now.month, now.day);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(1900),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDob = picked;
                      _dobCtrl.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
