import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key, required this.controller, required this.hintText, required this.iconData, this.validator, required this.obsureText,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData iconData;
  final String? Function(String?)? validator;
  final bool obsureText;


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obsureText,
      controller : controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
        ),
        filled: true,
        fillColor: Colors.black87,

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
            color: Colors.red,
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),


      ),
      validator: validator,
    );
  }
}