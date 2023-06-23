import 'package:flutter/material.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';

class NebulaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final bool loading;
  final NebulaButtonStyle? buttonStyle;

  const NebulaButton({
    this.text = '',
    this.loading = false,
    this.onPress,
    this.buttonStyle,
    super.key,
  });

  static const _borderRadius = BorderRadius.all(Radius.circular(6));
  static const _decoration = BoxDecoration(
    borderRadius: _borderRadius,
  );

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle ?? NebulaButtonStyle.primary(context);

    return InkWell(
      onTap: loading ? null : onPress,
      borderRadius: _borderRadius,
      child: Container(
        decoration: _decoration,
        constraints: const BoxConstraints(minWidth: 150, minHeight: 32),
        child: Ink(
          decoration: _decoration.copyWith(
            color: style.backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!loading)
                  Text(
                    text,
                    style: style.textStyle?.copyWith(color: style.textColor),
                  )
                else
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: style.indicatorColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NebulaButtonStyle {
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Color? textColor;
  final Color? indicatorColor;

  const NebulaButtonStyle({
    this.textStyle,
    this.textColor,
    this.backgroundColor,
    this.indicatorColor,
  });

  factory NebulaButtonStyle.primary(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: context.colors.primaryColors[AppColorsType.primary],
        textColor: context.colors.alternativeColors[AppColorsType.text],
        indicatorColor: context.colors.primaryColors[AppColorsType.indicator],
      );
}
