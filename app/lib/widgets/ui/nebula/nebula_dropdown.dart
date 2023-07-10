import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/overlay_option.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_form_field.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/overlay_follower.dart';

class NebulaDropdown<T> extends StatefulWidget {
  final bool loading;
  final FocusNode? focusNode;
  final List<OverlayOption<T>> options;
  final String? label;
  final OverlayOption<T>? selectedOption;
  final Function(OverlayOption<T> option)? onOptionSelected;
  final NebulaValidator? validator;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onListEndReached;

  const NebulaDropdown({
    this.options = const [],
    this.loading = false,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onListEndReached,
    this.selectedOption,
    this.onOptionSelected,
    this.label,
    this.validator,
    this.focusNode,
    super.key,
  });

  @override
  State<NebulaDropdown<T>> createState() => _NebulaDropdownState();
}

class _NebulaDropdownState<T> extends State<NebulaDropdown<T>> {
  late final FocusNode _focusNode;
  final _textController = TextEditingController();
  late ScrollController _scrollController;
  final _overlayController = GlobalKey<OverlayFollowerController>();

  static const _padding = EdgeInsetsDirectional.symmetric(
    horizontal: 8,
    vertical: 12,
  );
  static const _itemsPadding = EdgeInsetsDirectional.only(bottom: 4);
  static const _itemHeight = 36.0;

  double _getIndexOffset(int index) => index * _itemHeight
      + _padding.vertical
      + (index - 1) * _itemsPadding.vertical;

  double get _maxHeight => min(
    _getIndexOffset(widget.options.length),
    230,
  );


  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _scrollController = ScrollController()..addListener(_onRequestNewOptions);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (widget.selectedOption != null) {
      _textController.text = context.translate(widget.selectedOption!.title);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant NebulaDropdown<T> oldWidget) {
    if (oldWidget.selectedOption != widget.selectedOption) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textController.text = context.translate(
          widget.selectedOption?.title ?? '',
        );
      });
    }

    if (_scrollController.hasClients && widget.options != oldWidget.options) {
      final currentOffset = _scrollController.offset;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_overlayController.currentState?.isShown ?? false) {
          _overlayController.currentState?.updateOverlay();
          _scrollController.dispose();
          _scrollController = ScrollController(initialScrollOffset: currentOffset);
        }
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onRequestNewOptions);
    _scrollController.dispose();

    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayFollower(
    key: _overlayController,
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
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.options.length,
        padding: _padding,
        itemBuilder: (context, index) {
          final option = widget.options[index];

          var isSelected = option == widget.selectedOption;
          if (option.uniqueIndex != null &&
              widget.selectedOption?.uniqueIndex != null) {
            isSelected = option.uniqueIndex == widget.selectedOption!.uniqueIndex;
          }

          return Padding(
            padding: index < widget.options.length - 1
                ? _itemsPadding
                : EdgeInsets.zero,
            child: _OptionEntry(
              itemHeight: _itemHeight,
              selected: isSelected,
              option: option,
              onTap: () => _selectOption(option, controller),
            ),
          );
        },
      ),
    ),
    targetBuilder: (context, controller) => NebulaFormField(
      readOnly: true,
      focusNode: _focusNode,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      controller: _textController,
      label: widget.label,
      onTap: widget.loading
          ? null
          : () => _openDropdown(controller),
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: Align(
            alignment: AlignmentDirectional.center,
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: widget.loading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : FaIcon(
                  FontAwesomeIcons.chevronDown,
                  size: 16,
                  color: controller.isShown
                      ? context.colors.primary
                      : context.colors.text,
                ),
          ),
        ),
      ),
    ),
  );

  void _selectOption(OverlayOption<T> option, OverlayFollowerController controller) {
    _textController.text = context.translate(option.title);

    widget.onOptionSelected?.call(option);

    controller.setVisibility();
  }

  void _onRequestNewOptions() {
    if (widget.options.isEmpty || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final pageLoadTrigger = 0.7 * position.maxScrollExtent;
    final shouldLoadNextPage = position.pixels > pageLoadTrigger
        && !widget.loading;

    if (!shouldLoadNextPage) {
      return;
    }

    widget.onListEndReached?.call();
  }

  void _openDropdown(OverlayFollowerController controller) {
    controller.toggleOverlay();


    //_scrollController.jumpTo(value);
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
              ? context.colors.primary
              : Colors.transparent,
        ),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: NebulaText(
            context.translate(option.title),
            style: selected
                ? context.typography.withColor(
                    context.colors.isLight
                        ? context.colors.text
                        : context.colors.alternativeText,
                  )
                : context.typography,
          ),
        ),
      ),
    ),
  );
}
