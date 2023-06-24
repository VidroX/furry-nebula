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
        primary: colorTheme.theme.primary,
        onPrimary: colorTheme.theme.alternativePrimary,
        secondary: colorTheme.theme.secondary,
        onSecondary: colorTheme.theme.alternativeSecondary,
        error: colorTheme.theme.error,
        onError: colorTheme.theme.alternativeError,
        background: colorTheme.theme.backgroundColor,
        onBackground: colorTheme.theme.text,
        surface: colorTheme.theme.surfaceColor,
        onSurface: colorTheme.theme.text,
      ),
      indicatorColor: colorTheme.theme.indicator,
      primaryColor: colorTheme.theme.primary,
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
