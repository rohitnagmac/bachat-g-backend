import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bachat_core/bachat_core.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/admin_provider.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  
  bool _isLoading = false;
  bool _sendToAll = true;
  List<User> _selectedUsers = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AdminProvider>(context, listen: false).fetchUsers();
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AdminProvider>(context);
    final allUsers = userProvider.users;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Title (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Default: Bachat-G Admin'
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                      labelText: 'Body *',
                      border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Enter a body' : null,
                ),
                const SizedBox(height: 16),
                const Text('Attachment (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_imageFile != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _imageFile = null),
                        style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                const SizedBox(height: 16),
                SwitchListTile(
                    title: const Text('Send to All Users'),
                    value: _sendToAll,
                    onChanged: (val) {
                        setState(() {
                            _sendToAll = val;
                            if (val) _selectedUsers = [];
                        });
                    }
                ),
                if (!_sendToAll) ...[
                    const SizedBox(height: 8),
                    const Text('Select Users:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (userProvider.isLoadingUsers)
                        const Center(child: CircularProgressIndicator())
                    else
                        Container(
                            height: 200,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4)
                            ),
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: allUsers.length,
                                itemBuilder: (context, index) {
                                    final user = allUsers[index];
                                    final isSelected = _selectedUsers.contains(user);
                                    return CheckboxListTile(
                                        title: Text(user.fullName ?? user.email),
                                        subtitle: Text(user.email),
                                        value: isSelected,
                                        onChanged: (bool? value) {
                                            setState(() {
                                                if (value == true) {
                                                    _selectedUsers.add(user);
                                                } else {
                                                    _selectedUsers.remove(user);
                                                }
                                            });
                                        },
                                    );
                                },
                            ),
                        ),
                    if (!_sendToAll && _selectedUsers.isEmpty)
                        const Text('Please select at least one user', style: TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Notification'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_sendToAll && _selectedUsers.isEmpty) return;

    setState(() => _isLoading = true);

    final success = await Provider.of<AdminProvider>(context, listen: false).sendNotification(
        title: _titleController.text.isNotEmpty ? _titleController.text : null,
        body: _bodyController.text,
        imageFile: _imageFile,
        targetUserIds: _sendToAll ? null : _selectedUsers.map((u) => u.id!).toList()
    );

    setState(() => _isLoading = false);

    if (mounted) {
        if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification Sent!')));
            Navigator.pop(context);
        } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send. Check server logs.')));
        }
    }
  }
}
