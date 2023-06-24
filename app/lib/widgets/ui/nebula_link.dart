import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class NebulaLink<T> extends StatefulWidget {
  final PageRouteInfo<T> routeInfo;
  final bool replace;
  final String text;
  final NebulaLinkStyle? style;

  const NebulaLink({
    required this.routeInfo,
    required this.text,
    this.replace = false,
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
        onTap: widget.replace
            ? () => context.replaceRoute(widget.routeInfo)
            : () => context.pushRoute(widget.routeInfo),
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
