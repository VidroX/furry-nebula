import 'package:flutter/material.dart';

typedef NebulaValidator = String? Function(String? value);

class NebulaFormField extends StatelessWidget {
  final String? label;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final NebulaValidator? validator;
  final InputDecoration decoration;
  final TextEditingController? controller;
  final Function(String value)? onChanged;

  const NebulaFormField({
    this.validator,
    this.label,
    this.controller,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = false,
    this.decoration = const InputDecoration(),
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    autovalidateMode: autovalidateMode,
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    onChanged: onChanged,
    decoration: decoration.copyWith(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
