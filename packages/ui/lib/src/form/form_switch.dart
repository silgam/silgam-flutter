import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormSwitch extends StatelessWidget {
  const FormSwitch({
    super.key,
    required this.name,
    this.initialValue,
    required this.title,
    this.subtitle,
  });

  final String name;
  final bool? initialValue;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return FormBuilderSwitch(
      name: name,
      initialValue: initialValue,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.grey,
                ),
              )
              : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
