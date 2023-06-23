import 'dart:async';

import 'package:flutter/material.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension AppTheme on ThemeData {
  ThemeData customTheme({ AppColors? theme }) {
    final colorTheme = theme ?? AppColors.light();
    final appTheme = colorTheme.theme.isLight
        ? ThemeData.light(useMaterial3: false)
        : ThemeData.dark(useMaterial3: false);

    return appTheme.copyWith(
      extensions: [colorTheme],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colorTheme.theme.primaryColors[AppColorsType.primary]!,
        onPrimary: colorTheme.theme.alternativeColors[AppColorsType.primary]!,
        secondary: colorTheme.theme.primaryColors[AppColorsType.secondary]!,
        onSecondary: colorTheme.theme.alternativeColors[AppColorsType.secondary]!,
        error: colorTheme.theme.primaryColors[AppColorsType.error]!,
        onError: colorTheme.theme.alternativeColors[AppColorsType.error]!,
        background: colorTheme.theme.backgroundColor,
        onBackground: colorTheme.theme.primaryColors[AppColorsType.text]!,
        surface: colorTheme.theme.surfaceColor,
        onSurface: colorTheme.theme.primaryColors[AppColorsType.text]!,
      ),
      indicatorColor: colorTheme.theme.primaryColors[AppColorsType.indicator],
      primaryColor: colorTheme.theme.primaryColors[AppColorsType.primary],
      inputDecorationTheme: const InputDecorationTheme(
        helperMaxLines: 2,
        errorMaxLines: 2,
      ),
    );
  }
}

class AppThemeProvider extends ChangeNotifier {
  AppColorsTheme theme;

  AppThemeProvider({ required this.theme });

  FutureOr<void> changeTheme(AppColorsTheme? newTheme) async {
    theme = newTheme ?? AppColorsTheme.light();
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppColors.themeKey, theme.themeName.name);
  }
}
