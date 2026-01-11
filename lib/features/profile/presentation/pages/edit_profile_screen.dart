import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lotex/core/theme/app_colors.dart';
import 'package:lotex/core/widgets/app_input.dart';
import 'package:lotex/core/widgets/app_button.dart';
// import 'package:lotex/core/theme/app_text_styles.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  XFile? _imageFile;
  Uint8List? _imageBytes;
  String? _initialPhotoUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    // phone loaded from Firestore if exists
    if (user != null) {
      _initialPhotoUrl = user.photoURL;
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null && mounted) {
            _phoneController.text = data['phone'] ?? '';
            setState(() {});
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageFile = picked;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Користувач не авторизований');

      String? photoUrl = user.photoURL;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.name}');
        final uploadTask = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        photoUrl = await uploadTask.ref.getDownloadURL();
        await user.updatePhotoURL(photoUrl);
      }

      final newName = _nameController.text.trim();
      if (newName.isNotEmpty && newName != user.displayName) {
        await user.updateDisplayName(newName);
      }

      // update Firestore users doc
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // update public profile doc
      await FirebaseFirestore.instance.collection('public_profiles').doc(user.uid).set({
        'displayName': newName,
        'photoURL': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Ensure FirebaseAuth emits updated user
      await user.reload();

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: ${humanError(e)}')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редагувати профіль')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _saving ? null : _pickImage,
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: AppColors.primary500,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_initialPhotoUrl != null ? NetworkImage(_initialPhotoUrl!) as ImageProvider : null),
                    child: (_imageBytes == null && _initialPhotoUrl == null) ? const Icon(Icons.camera_alt, size: 32, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(height: 16),
                AppInput(label: 'Ім\'я', controller: _nameController, validator: (v) => v == null || v.isEmpty ? 'Введіть ім\'я' : null),
                const SizedBox(height: 12),
                AppInput(label: 'Телефон', controller: _phoneController, keyboardType: TextInputType.phone),
                const SizedBox(height: 24),
                AppButton.primary(
                  label: _saving ? 'Збереження...' : 'Зберегти',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  // no-op
}
