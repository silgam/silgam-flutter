import 'package:flutter/material.dart';

class OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;

  const OutlinedTextField({
    Key? key,
    required this.controller,
    required this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isCollapsed: true,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            suffix,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minHeight: 0),
        contentPadding: const EdgeInsets.only(top: 4, bottom: 4, left: 8),
      ),
    );
  }
}
