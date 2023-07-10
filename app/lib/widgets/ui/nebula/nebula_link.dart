import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

class NebulaLink<T> extends StatefulWidget {
  final String text;
  final NebulaLinkStyle? style;
  final VoidCallback? onTap;

  const NebulaLink({
    required this.text,
    this.onTap,
    this.style,
    super.key,
  });

  @override
  State<NebulaLink<T>> createState() => _NebulaLinkState<T>();
}

class _NebulaLinkState<T> extends State<NebulaLink<T>> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final linkStyle = widget.style ?? NebulaLinkStyle.primary(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isHovering = true),
        onTapUp: (_) => setState(() => _isHovering = false),
        onHorizontalDragStart: (_) => setState(() => _isHovering = false),
        onVerticalDragStart: (_) => setState(() => _isHovering = false),
        child: NebulaText(
          widget.text,
          style: context.typography.withColor(
            _isHovering
                ? linkStyle.hoveringColor
                : linkStyle.color,
          ),
        ),
      ),
    );
  }
}

class NebulaLinkStyle {
  final Color color;
  final Color hoveringColor;

  const NebulaLinkStyle({
    required this.color,
    required this.hoveringColor,
  });

  factory NebulaLinkStyle.primary(BuildContext context) =>
      NebulaLinkStyle(
        color: context.colors.primary,
        hoveringColor: context.colors.primary.withAlpha(150),
      );
}
