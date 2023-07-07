import 'package:flutter/material.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';

class NebulaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPress;
  final bool loading;
  final NebulaButtonStyle? buttonStyle;
  final double? width;
  final double? height;
  final Widget? prefixChild;
  final Widget? suffixChild;

  const NebulaButton({
    this.text = '',
    this.loading = false,
    this.onPress,
    this.buttonStyle,
    this.width,
    this.height,
    this.prefixChild,
    this.suffixChild,
    super.key,
  });

  factory NebulaButton.fill({
    String text = '',
    bool loading = false,
    VoidCallback? onPress,
    NebulaButtonStyle? buttonStyle,
    double? height,
  }) => NebulaButton(
    text: text,
    loading: loading,
    onPress: onPress,
    buttonStyle: buttonStyle,
    height: height,
    width: double.maxFinite,
  );

  static const _padding = EdgeInsetsDirectional.symmetric(
    vertical: 8,
    horizontal: 12,
  );

  @override
  Widget build(BuildContext context) {
    final style = buttonStyle ?? NebulaButtonStyle.primary(context);
    final size = style.textStyle.fontSize * style.textStyle.lineHeight;

    return Material(
      color: style.backgroundColor,
      borderRadius: style.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 150,
          minHeight: size + _padding.vertical,
        ),
        width: width,
        height: height,
        child: InkWell(
          splashColor: style.splashColor,
          highlightColor: style.highlightColor,
          onTap: loading ? null : onPress,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: style.borderRadius,
              border: style.border,
            ),
            child: Padding(
              padding: _padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!loading) ...[
                    if (prefixChild != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: prefixChild,
                      ),
                    NebulaText(
                      text,
                      style: style.textStyle,
                    ),
                    if (suffixChild != null)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: suffixChild,
                      ),
                  ]
                  else
                    SizedBox(
                      width: size,
                      height: size,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: style.indicatorColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NebulaButtonStyle {
  final Color backgroundColor;
  final Color? highlightColor;
  final NebulaTextStyle textStyle;
  final Color indicatorColor;
  final Color splashColor;
  final Border? border;
  final BorderRadius borderRadius;

  const NebulaButtonStyle({
    required this.textStyle,
    required this.backgroundColor,
    required this.indicatorColor,
    required this.splashColor,
    required this.borderRadius,
    this.highlightColor,
    this.border,
  });

  factory NebulaButtonStyle.primary(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: context.colors.primary,
        textStyle: context.typography.withColor(
          context.colors.isLight
              ? context.colors.text
              : context.colors.alternativeText,
        ),
        indicatorColor: context.colors.indicator,
        splashColor: context.colors.indicator,
        border: Border.all(color: context.colors.primary),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.outlinedPrimary(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: Colors.transparent,
        textStyle: context.typography.withColor(context.colors.primary),
        indicatorColor: context.colors.primary,
        highlightColor: context.colors.primary.withOpacity(0.15),
        splashColor: context.colors.primary.withOpacity(0.05),
        border: Border.all(color: context.colors.primary),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.background(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: context.colors.backgroundColor,
        textStyle: context.typography.withColor(context.colors.text),
        indicatorColor: context.colors.primary,
        splashColor: context.colors.primary,
        border: Border.all(color: context.colors.backgroundColor),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.outlinedBackground(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: Colors.transparent,
        textStyle: context.typography.withColor(context.colors.backgroundColor),
        indicatorColor: context.colors.backgroundColor,
        highlightColor: context.colors.backgroundColor.withOpacity(0.15),
        splashColor: context.colors.backgroundColor.withOpacity(0.05),
        border: Border.all(color: context.colors.backgroundColor),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.clear(BuildContext context, { bool isLight = true }) =>
      NebulaButtonStyle(
        backgroundColor: Colors.transparent,
        textStyle: context.typography.withColor(
          isLight
              ? context.colors.text
              : context.colors.alternativeText,
        ),
        indicatorColor: context.colors.backgroundColor,
        splashColor: context.colors.primary,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.error(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: context.colors.error,
        textStyle: context.typographyAlt,
        indicatorColor: context.colors.alternativeText,
        splashColor: context.colors.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );

  factory NebulaButtonStyle.outlinedError(BuildContext context) =>
      NebulaButtonStyle(
        backgroundColor: Colors.transparent,
        textStyle: context.typography.withColor(context.colors.error),
        indicatorColor: context.colors.error,
        highlightColor: context.colors.error.withOpacity(0.15),
        splashColor: context.colors.error.withOpacity(0.05),
        border: Border.all(color: context.colors.error),
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      );
}
