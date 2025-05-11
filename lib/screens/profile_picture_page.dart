import 'dart:io';
import 'package:flutter/material.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/utils/image_picker_util.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Picture'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const PageHeader(
                title: 'Set Your Profile Picture',
                subtitle: 'Choose a profile picture to personalize your account',
              ),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () {
                    ImagePickerUtil.showImageSourceDialog(
                      context: context,
                      onImageSelected: (image) {
                        if (image != null) {
                          setState(() {
                            _selectedImage = image;
                          });
                        }
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.darkGray,
                          shape: BoxShape.circle,
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: AppTheme.lightGray,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.neonGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppTheme.darkCanvas,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Next',
                onPressed: () {
                  // Navigate to home page instead of select members page
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}