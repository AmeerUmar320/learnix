import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_app/theme.dart';
import 'package:group_chat_app/utils/image_picker_util.dart';
import 'package:group_chat_app/widgets/common_widgets.dart';
import '../blocs/auth/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePicturePage extends StatefulWidget {
  const ProfilePicturePage({super.key});

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  File? _selectedImage;
  bool _isLoading = false;
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
  }

  void _onNextPressed() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }
    setState(() => _isLoading = true);

    _authBloc.add(ProfileSubmittedWithImage(_selectedImage!));

    final subscription = _authBloc.stream.listen((state) async {
      if (state is AuthSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', true);
        await prefs.setInt('userId', state.user.id);
        // Already stored userName and profilePictureUrl in Bloc
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (state is AuthFailure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        setState(() => _isLoading = false);
      }
    });
    Future.delayed(const Duration(seconds: 5), () => subscription.cancel());
  }

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
              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      text: 'Next',
                      onPressed: _onNextPressed,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
