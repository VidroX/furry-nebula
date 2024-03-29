import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:intl/intl.dart';

typedef NebulaValidator = String? Function(String? value);

class NebulaDatePickerField extends StatefulWidget {
  final String? label;
  final AutovalidateMode autovalidateMode;
  final NebulaValidator? validator;
  final InputDecoration decoration;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final DatePickerMode initialDatePickerMode;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime date)? onDateSelected;

  const NebulaDatePickerField({
    this.validator,
    this.label,
    this.controller,
    this.focusNode,
    this.onDateSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.initialDatePickerMode = DatePickerMode.year,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.decoration = const InputDecoration(),
    super.key,
  });

  @override
  State<NebulaDatePickerField> createState() => _NebulaDatePickerFieldState();
}

class _NebulaDatePickerFieldState extends State<NebulaDatePickerField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    readOnly: true,
    autovalidateMode: widget.autovalidateMode,
    controller: _controller,
    validator: widget.validator,
    onTap: _showDatePickerDialog,
    focusNode: _focusNode,
    decoration: widget.decoration.copyWith(
      labelText: widget.label,
      border: const OutlineInputBorder(),
      suffixIcon: const Padding(
        padding: EdgeInsetsDirectional.only(end: 8),
        child: Align(
          alignment: AlignmentDirectional.center,
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: FaIcon(
            FontAwesomeIcons.calendar,
            size: 24,
          ),
        ),
      ),
    ),
  );

  Future<void> _showDatePickerDialog() async {
    if (!context.mounted) {
      return;
    }

    final colorScheme = context.colors.isLight
        ? const ColorScheme.light()
        : const ColorScheme.dark();

    final date = await showDatePicker(
      context: context,
      initialDatePickerMode: widget.initialDatePickerMode,
      initialDate: widget.initialDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(DateTime.now().year - 100),
      lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 100),
      builder: (context, child) => Theme(
        data: context.theme.copyWith(
          colorScheme: colorScheme.copyWith(
            primary: context.colors.primary,
            onPrimary: context.colors.isLight
                ? context.colors.text
                : context.colors.alternativeText,
            surface: context.colors.containerColor,
            onSurface: context.colors.text,
          ),
          datePickerTheme: context.theme.datePickerTheme.copyWith(
            backgroundColor: context.colors.containerColor,
            headerBackgroundColor: context.colors.containerColor,
            surfaceTintColor: context.colors.containerColor,
          ),
        ),
        child: child!,
      ),
    );

    if (date == null) {
      return;
    }

    widget.onDateSelected?.call(date);

    final formatter = DateFormat(DateFormat.YEAR_MONTH_DAY, Platform.localeName);

    _controller.text = formatter.format(DateUtils.dateOnly(date));
  }
}
