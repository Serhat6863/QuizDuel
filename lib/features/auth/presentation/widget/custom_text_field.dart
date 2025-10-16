import 'package:flutter/material.dart';
import 'package:quizduel/core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconData,
    this.validator,
    required this.obsureText,
    this.onTap, required this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData iconData;
  final String? Function(String?)? validator;
  final bool obsureText;
  final void Function()? onTap;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obsureText,
      style: const TextStyle(color: Colors.white),
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        errorStyle: TextStyle(
          color: AppColors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          height: 1.5,
        ),
        prefixIcon: Icon(
          iconData,
          color: AppColors.white,
        ),
        suffixIcon: onTap != null
            ? GestureDetector(
          onTap: onTap,
          child: Icon(
            obsureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.white,
          ),
        )
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
        ),
        filled: true,
        fillColor: AppColors.filledTextField,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
      ),
    );
  }
}
