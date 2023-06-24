import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';

part 'nebula_text.freezed.dart';

class NebulaText extends StatelessWidget {
  final String text;
  final NebulaTextStyle? style;
  final int? maxLines;

  const NebulaText(
    this.text, {
      this.style,
      this.maxLines,
      super.key,
    }
  );

  @override
  Widget build(BuildContext context) {
    final typographyStyle = style ?? context.typography;

    return Text(
      text,
      style: typographyStyle.toTextStyle(),
      maxLines: maxLines,
    );
  }
}

@freezed
class NebulaTextStyle with _$NebulaTextStyle {
  const factory NebulaTextStyle({
    @Default(Colors.black) Color color,
    @Default(16) double fontSize,
    @Default(1.5) double lineHeight,
    @Default(FontWeight.w400) FontWeight fontWeight,
  }) = _NebulaTextStyle;

  const NebulaTextStyle._();

  TextStyle toTextStyle() => TextStyle(
    color: color,
    fontSize: fontSize,
    height: lineHeight,
    fontWeight: fontWeight,
  );

  NebulaTextStyle withCustomFontSize(double fontSize) => copyWith(
    fontSize: fontSize,
  );

  NebulaTextStyle withFontSize(AppFontSize fontSize) => copyWith(
    fontSize: fontSize.asValue,
  );

  NebulaTextStyle withFontWeight(FontWeight fontWeight) => copyWith(
    fontWeight: fontWeight,
  );

  NebulaTextStyle withColor(Color color) => copyWith(
    color: color,
  );
}

enum AppFontSize {
  extraSmall,
  small,
  normal,
  large,
  extraLarge,
  huge;

  double get asValue => {
    extraSmall: 12.0,
    small: 14.0,
    normal: 16.0,
    large: 24.0,
    extraLarge: 28.0,
    huge: 32.0,
  }[this] ?? 14.0;
}
