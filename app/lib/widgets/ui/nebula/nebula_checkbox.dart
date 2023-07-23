import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class NebulaCheckbox extends StatelessWidget {
  final bool triMode;
  final String? title;
  final bool? value;
  final Function(bool? newValue)? onChanged;
  final NebulaCheckboxSize size;
  final int maxLines;

  const NebulaCheckbox({
    this.triMode = false,
    this.size = NebulaCheckboxSize.small,
    this.maxLines = 1,
    this.title,
    this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return _CheckboxContainer(size: size, value: value, onChanged: onChanged);
    }

    return GestureDetector(
      onTap: () => onChanged?.call(!(value ?? false)),
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          _CheckboxContainer(size: size, value: value, onChanged: onChanged),
          const SizedBox(width: 8),
          Expanded(
            child: NebulaText(
              title!,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

enum NebulaCheckboxSize {
  small,
  medium,
  large;

  double get toDouble => {
    small: 28.0,
    medium: 36.0,
    large: 48.0,
  }[this] ?? 28.0;
}

class _CheckboxContainer extends StatefulWidget {
  final bool triMode;
  final bool? value;
  final Function(bool? newValue)? onChanged;
  final NebulaCheckboxSize size;

  const _CheckboxContainer({
    this.triMode = false,
    this.size = NebulaCheckboxSize.small,
    this.value,
    this.onChanged,
    super.key,
  });

  @override
  State<_CheckboxContainer> createState() => _CheckboxContainerState();
}

class _CheckboxContainerState extends State<_CheckboxContainer> {
  IconData? _getIcon() {
    if (widget.value == null && widget.triMode) {
      return FontAwesomeIcons.minus;
    }

    if (widget.value ?? false) {
      return FontAwesomeIcons.check;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();

    return AnimatedContainer(
      width: widget.size.toDouble,
      height: widget.size.toDouble,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: (widget.value == null && widget.triMode) || (widget.value ?? false)
              ? context.colors.primary
              : context.colors.text,
        ),
        color: (widget.value == null && widget.triMode) || (widget.value ?? false)
            ? context.colors.primary
            : Colors.transparent,
      ),
      duration: const Duration(milliseconds: 150),
      child: icon != null ? Center(
        child: FaIcon(
          icon,
          size: widget.size.toDouble - 12,
        ),
      ) : const SizedBox.shrink(),
    );
  }
}
