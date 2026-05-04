import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/user_provider.dart';

Future<void> showAvatarOptions(BuildContext context, WidgetRef ref) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Choisir une photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionButton(
                icon: Icons.photo_library,
                label: 'Galerie',
                onTap: () => _pickImage(context, ref, ImageSource.gallery),
              ),
              _OptionButton(
                icon: Icons.camera_alt,
                label: 'Caméra',
                onTap: () => _pickImage(context, ref, ImageSource.camera),
              ),
              _OptionButton(
                icon: Icons.folder,
                label: 'Fichiers',
                onTap: () => _pickFile(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9E6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFFFFC107),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}

final ImagePicker _picker = ImagePicker();

Future<void> _pickImage(
    BuildContext context, WidgetRef ref, ImageSource source) async {
  Navigator.pop(context); // fermer la modale
  try {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (image != null) {
      if (!context.mounted) return;
      await _uploadAvatar(File(image.path), context, ref);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}

Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
  Navigator.pop(context); // fermer la modale
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: true,
    );
    if (result != null && result.files.single.path != null) {
      if (!context.mounted) return;
      await _uploadAvatar(File(result.files.single.path!), context, ref);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}

Future<void> _uploadAvatar(
    File imageFile, BuildContext context, WidgetRef ref) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(color: Color(0xFFFFC107)),
    ),
  );

  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Non connecté');

    final fileExt = imageFile.path.split('.').last;
    final path = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await supabase.storage.from('avatars').upload(path, imageFile);
    final url = supabase.storage.from('avatars').getPublicUrl(path);

    await ref.read(userProvider.notifier).updateProfile(avatarUrl: url);

    if (context.mounted) {
      Navigator.pop(context); // Remove loader
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context); // Remove loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'upload: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFF4D4D),
        ),
      );
    }
  }
}
