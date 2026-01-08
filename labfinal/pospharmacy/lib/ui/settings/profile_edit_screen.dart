import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    nameController.text = authProvider.userName ?? "";
    emailController.text = authProvider.userEmail ?? "";
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
      final dir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${dir.path}/assets');
      if (!await assetsDir.exists()) await assetsDir.create(recursive: true);
      final filePath = '${assetsDir.path}/img.png';
      await _profileImage!.copy(filePath);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.userEmail;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        // optionally: add profileImage URL if uploading to Firebase Storage
      });
      authProvider.userName = nameController.text.trim();
    }
    setState(() => _loading = false);

    NotificationService().showNotification(
      context: context,
      title: "Profile Saved",
      body: "Your profile details have been updated",
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/img.png') as ImageProvider,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: _loading ? "Saving..." : "Save",
                onPressed: _loading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
