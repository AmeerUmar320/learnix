// import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;   // <-- nullable
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,       // now nullable
    this.isLoading = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // if isLoading, we disable; otherwise pass whatever nullable callback
        onPressed: isLoading ? null : onPressed,
        style: AppTheme.primaryButtonStyle,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.darkCanvas,
                ),
              )
            : Text(text),
      ),
    );
  }
}


class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon, suffixIcon;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: AppTheme.inputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppTheme.headingStyle),
      if (subtitle != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle!, style: AppTheme.captionStyle),
        ),
      const SizedBox(height: 24),
    ]);
  }
}
