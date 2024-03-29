import 'package:flutter/material.dart';

typedef NebulaValidator = String? Function(String? value);

class NebulaFormField extends StatelessWidget {
  final FocusNode? focusNode;
  final String? label;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final int? maxLines;
  final NebulaValidator? validator;
  final InputDecoration decoration;
  final TextEditingController? controller;
  final Function(String value)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const NebulaFormField({
    this.focusNode,
    this.validator,
    this.label,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.obscureText = false,
    this.decoration = const InputDecoration(),
    super.key,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    focusNode: focusNode,
    autovalidateMode: autovalidateMode,
    controller: controller,
    obscureText: obscureText,
    validator: validator,
    onChanged: onChanged,
    maxLines: maxLines,
    onTap: onTap,
    readOnly: readOnly,
    decoration: decoration.copyWith(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
