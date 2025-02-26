import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, this.onChanged, this.hintText});

  final ValueChanged<String>? onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      cursorWidth: 1,
      cursorColor: Colors.grey.shade700,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        isCollapsed: true,
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: hintText,
        hintStyle: const TextStyle(fontWeight: FontWeight.w300),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
