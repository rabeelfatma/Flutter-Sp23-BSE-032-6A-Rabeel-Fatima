import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  String? _savedImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    nameController.text = auth.userName ?? "";
    emailController.text = auth.userEmail ?? "";
    _savedImagePath = auth.profileImagePath;
    if (_savedImagePath != null) {
      _profileImage = File(_savedImagePath!);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final assetsDir = Directory('${dir.path}/profile');
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }

    final path = '${assetsDir.path}/profile.png';
    final savedFile = await File(pickedFile.path).copy(path);

    setState(() {
      _profileImage = savedFile;
      _savedImagePath = path;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.updateProfile(
      name: nameController.text.trim(),
      imagePath: _savedImagePath,
    );

    setState(() => _loading = false);

    if (success) {
      NotificationService().showNotification(
        context: context,
        title: "Profile Saved",
        body: "Your profile has been updated",
      );
      Navigator.pop(context);
    }
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
                        : const AssetImage('assets/img.png')
                    as ImageProvider,
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
                readOnly: true,
                decoration: const InputDecoration(labelText: "Email"),
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
