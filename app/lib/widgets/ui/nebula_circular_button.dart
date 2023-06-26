import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';

class NebulaCircularButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPress;
  final bool loading;
  final NebulaCircularButtonStyle? buttonStyle;
  final double size;

  const NebulaCircularButton({
    required this.child,
    this.loading = false,
    this.onPress,
    this.buttonStyle,
    this.size = 48,
    super.key,
  });

  static const _padding = EdgeInsetsDirectional.all(4);

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle ?? NebulaCircularButtonStyle.primary(context);

    return Material(
      color: style.backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: const CircleBorder(),
      child: InkWell(
        splashColor: style.splashColor,
        highlightColor: style.highlightColor,
        onTap: loading ? null : onPress,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: style.border,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: _padding,
            child: Center(
              child: loading ? SizedBox(
                width: (size - _padding.vertical) / 2,
                height: (size - _padding.vertical) / 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: style.indicatorColor,
                ),
              ) : child,
            ),
          ),
        ),
      ),
    );
  }
}

class NebulaCircularButtonStyle {
  final Color backgroundColor;
  final Color? highlightColor;
  final Color indicatorColor;
  final Color splashColor;
  final Border? border;

  const NebulaCircularButtonStyle({
    required this.backgroundColor,
    required this.indicatorColor,
    required this.splashColor,
    this.highlightColor,
    this.border,
  });

  factory NebulaCircularButtonStyle.primary(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: context.colors.primary,
        indicatorColor: context.colors.indicator,
        splashColor: context.colors.indicator,
      );

  factory NebulaCircularButtonStyle.outlinedPrimary(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: Colors.transparent,
        indicatorColor: context.colors.primary,
        highlightColor: context.colors.primary.withOpacity(0.15),
        splashColor: context.colors.primary.withOpacity(0.05),
        border: Border.all(color: context.colors.primary, width: 2),
      );

  factory NebulaCircularButtonStyle.background(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: context.colors.backgroundColor,
        indicatorColor: context.colors.primary,
        splashColor: context.colors.primary,
      );

  factory NebulaCircularButtonStyle.outlinedBackground(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: Colors.transparent,
        indicatorColor: context.colors.backgroundColor,
        highlightColor: context.colors.backgroundColor.withOpacity(0.15),
        splashColor: context.colors.backgroundColor.withOpacity(0.05),
        border: Border.all(color: context.colors.backgroundColor, width: 2),
      );

  factory NebulaCircularButtonStyle.clear(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: Colors.transparent,
        indicatorColor: context.colors.backgroundColor,
        splashColor: context.colors.primary,
      );

  factory NebulaCircularButtonStyle.error(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: context.colors.error,
        indicatorColor: context.colors.alternativeText,
        splashColor: context.colors.secondary,
      );

  factory NebulaCircularButtonStyle.outlinedError(BuildContext context) =>
      NebulaCircularButtonStyle(
        backgroundColor: Colors.transparent,
        indicatorColor: context.colors.error,
        highlightColor: context.colors.error.withOpacity(0.15),
        splashColor: context.colors.error.withOpacity(0.05),
        border: Border.all(color: context.colors.error, width: 2),
      );
}
