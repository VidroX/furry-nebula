import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef NebulaValidator = String? Function(String? value);

class NebulaPasswordField extends StatefulWidget {
  final String? label;
  final AutovalidateMode autovalidateMode;
  final NebulaValidator? validator;
  final InputDecoration decoration;
  final TextEditingController? controller;
  final Function(String value)? onChanged;

  const NebulaPasswordField({
    this.validator,
    this.label,
    this.controller,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.decoration = const InputDecoration(),
    super.key,
  });

  @override
  State<NebulaPasswordField> createState() => _NebulaPasswordFieldState();
}

class _NebulaPasswordFieldState extends State<NebulaPasswordField> {
  bool _isPasswordShown = false;

  @override
  Widget build(BuildContext context) => TextFormField(
    autovalidateMode: widget.autovalidateMode,
    controller: widget.controller,
    obscureText: !_isPasswordShown,
    validator: widget.validator,
    onChanged: widget.onChanged,
    decoration: widget.decoration.copyWith(
      labelText: widget.label,
      border: const OutlineInputBorder(),
      suffixIcon: Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => setState(() => _isPasswordShown = !_isPasswordShown),
            behavior: HitTestBehavior.translucent,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: FaIcon(
                _isPasswordShown
                    ? FontAwesomeIcons.eye
                    : FontAwesomeIcons.eyeSlash,
                key: ValueKey<bool>(_isPasswordShown),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
