import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/app_theme.dart';
import 'package:furry_nebula/widgets/nebula_text.dart';
import 'package:provider/provider.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppColorsTheme get colors =>
      theme.extension<AppColors>()?.theme ?? AppColorsTheme.light();

  AppThemeProvider get themeProvider =>
      Provider.of<AppThemeProvider>(this, listen: false);

  NebulaTextStyle get typography => NebulaTextStyle(
    color: colors.primaryColors[AppColorsType.text]!,
    fontSize: AppFontSize.normal.asValue,
  );

  String translate(String key, {
    String? fallbackKey,
    Map<String, String>? params,
  }) => FlutterI18n.translate(
    this,
    key,
    fallbackKey: fallbackKey,
    translationParams: params,
  );

  String translatePlural(String key, int pluralValue) => FlutterI18n.plural(
    this,
    key,
    pluralValue,
  );
}
