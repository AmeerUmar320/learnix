import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Helper to show camera/gallery picker and return a File.
class ImagePickerUtil {
  static Future<File?> showImageSourceDialog({
    required BuildContext context,
    required void Function(File?) onImageSelected,
  }) async {
    final picker = ImagePicker();
    File? result;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo'),
            onTap: () async {
              Navigator.pop(context);
              final file = await picker.pickImage(source: ImageSource.camera);
              result = file != null ? File(file.path) : null;
              onImageSelected(result);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              Navigator.pop(context);
              final file = await picker.pickImage(source: ImageSource.gallery);
              result = file != null ? File(file.path) : null;
              onImageSelected(result);
            },
          ),
        ]),
      ),
    );
    return result;
  }
}
