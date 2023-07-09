import 'dart:math';

import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/overlay_option.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_form_field.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/overlay_follower.dart';

class NebulaDropdown<T> extends StatefulWidget {
  final List<OverlayOption<T>> options;
  final String? label;
  final OverlayOption<T>? selectedOption;
  final Function(OverlayOption<T> option)? onOptionSelected;
  final NebulaValidator? validator;
  final AutovalidateMode autovalidateMode;

  const NebulaDropdown({
    this.options = const [],
    this.autovalidateMode = AutovalidateMode.disabled,
    this.selectedOption,
    this.onOptionSelected,
    this.label,
    this.validator,
    super.key,
  });

  @override
  State<NebulaDropdown<T>> createState() => _NebulaDropdownState();
}

class _NebulaDropdownState<T> extends State<NebulaDropdown<T>> {
  final _textController = TextEditingController();

  static const _padding = EdgeInsetsDirectional.symmetric(
    horizontal: 8,
    vertical: 12,
  );
  static const _itemsPadding = EdgeInsetsDirectional.only(bottom: 4);

  static const _itemHeight = 36.0;

  double get _maxHeight => min(
    widget.options.length.toDouble() * _itemHeight
        + _padding.vertical
        + (widget.options.length.toDouble() - 1) * _itemsPadding.vertical,
    230,
  );

  @override
  void didChangeDependencies() {
    if (widget.selectedOption != null) {
      _textController.text = context.translate(widget.selectedOption!.title);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayFollower(
    height: _maxHeight,
    overlayBuilder: (context, controller) => Container(
      decoration: BoxDecoration(
        color: context.colors.backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        boxShadow: context.colors.shadow,
      ),
      clipBehavior: Clip.antiAlias,
      height: _maxHeight,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.options.length,
        padding: _padding,
        itemBuilder: (context, index) {
          final option = widget.options[index];

          return Padding(
            padding: index < widget.options.length - 1
                ? _itemsPadding
                : EdgeInsets.zero,
            child: _OptionEntry(
              itemHeight: _itemHeight,
              selected: option == widget.selectedOption,
              option: option,
              onTap: () => _selectOption(option, controller),
            ),
          );
        },
      ),
    ),
    targetBuilder: (context, controller) => NebulaFormField(
      readOnly: true,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      controller: _textController,
      label: widget.label,
      onTap: controller.toggleOverlay,
    ),
  );

  void _selectOption(OverlayOption<T> option, OverlayFollowerActions controller) {
    _textController.text = context.translate(option.title);

    widget.onOptionSelected?.call(option);

    controller.setVisibility();
  }
}

class _OptionEntry<T> extends StatelessWidget {
  final bool selected;
  final OverlayOption<T> option;
  final VoidCallback? onTap;
  final double itemHeight;

  static const _borderRadius = BorderRadius.all(Radius.circular(6));

  const _OptionEntry({
    required this.option,
    required this.itemHeight,
    this.selected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: _borderRadius,
      child: Ink(
        height: itemHeight,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: selected
              ? context.colors.containerColor
              : Colors.transparent,
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: NebulaText(context.translate(option.title)),
        ),
      ),
    ),
  );
}

