import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_colors.freezed.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  static const String themeKey = 'theme';

  final AppColorsTheme theme;

  const AppColors({ required this.theme });

  factory AppColors.fromThemeName(AppThemeName themeName) {
    switch (themeName) {
      case AppThemeName.light:
        return AppColors.light();
      case AppThemeName.dark:
        return AppColors.dark();
      default:
        return AppColors.light();
    }
  }

  factory AppColors.light() => AppColors(theme: AppColorsTheme.light());
  factory AppColors.dark() => AppColors(theme: AppColorsTheme.dark());

  @override
  ThemeExtension<AppColors> copyWith({ AppColorsTheme? theme }) => AppColors(
    theme: theme ?? this.theme,
  );

  @override
  ThemeExtension<AppColors> lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      theme: theme.copyWith(
        backgroundColor: Color.lerp(
          theme.backgroundColor,
          other.theme.backgroundColor,
          t,
        ) ?? theme.backgroundColor,
        surfaceColor: Color.lerp(
          theme.surfaceColor,
          other.theme.surfaceColor,
          t,
        ) ?? theme.surfaceColor,
        primaryColors: theme.primaryColors.map((key, value) =>
            MapEntry(
              key,
              Color.lerp(value, other.theme.primaryColors[key], t) ?? value,
            ),
        ),
        alternativeColors: theme.alternativeColors.map((key, value) =>
            MapEntry(
              key,
              Color.lerp(value, other.theme.alternativeColors[key], t) ?? value,
            ),
        ),
      ),
    );
  }
}

@freezed
class AppColorsTheme with _$AppColorsTheme {
  const factory AppColorsTheme({
    required AppThemeName themeName,
    required bool isLight,
    required Color backgroundColor,
    required Color surfaceColor,
    required Map<AppColorsType, Color> primaryColors,
    required Map<AppColorsType, Color> alternativeColors,
  }) = _AppColorsTheme;

  const AppColorsTheme._();

  factory AppColorsTheme.fromString(String? themeName) {
    final appThemeName = AppThemeName.fromString(themeName);

    switch (appThemeName) {
      case AppThemeName.light:
        return AppColorsTheme.light();
      case AppThemeName.dark:
        return AppColorsTheme.dark();
      default:
        return AppColorsTheme.light();
    }
  }

  factory AppColorsTheme.light() => const AppColorsTheme(
    themeName: AppThemeName.light,
    isLight: true,
    backgroundColor: Color(0xFFFFFFFF),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColors: {
      AppColorsType.primary: Color(0xFF7FEFBD),
      AppColorsType.secondary: Color(0xFF6B7FD7),
      AppColorsType.text: Color(0xFF1B1B1E),
      AppColorsType.indicator: Color(0xFF6B7FD7),
      AppColorsType.error: Color(0xFFFF785A),
    },
    alternativeColors: {
      AppColorsType.primary: Color(0xFF1B1B1E),
      AppColorsType.secondary: Color(0xFFF3EFE0),
      AppColorsType.text: Color(0xFFFFFFFF),
      AppColorsType.indicator: Color(0xFFF3EFE0),
      AppColorsType.error: Color(0xFFF3EFE0),
    },
  );

  factory AppColorsTheme.dark() => const AppColorsTheme(
    themeName: AppThemeName.dark,
    isLight: false,
    backgroundColor: Color(0xFF1B1B1E),
    surfaceColor: Color(0xFFFFFFFF),
    primaryColors: {
      AppColorsType.primary: Color(0xFF7FEFBD),
      AppColorsType.secondary: Color(0xFF6B7FD7),
      AppColorsType.text: Color(0xFFFFFFFF),
      AppColorsType.indicator: Color(0xFF6B7FD7),
      AppColorsType.error: Color(0xFFFF785A),
    },
    alternativeColors: {
      AppColorsType.primary: Color(0xFFFFFFFF),
      AppColorsType.secondary: Color(0xFFF3EFE0),
      AppColorsType.text: Color(0xFF1B1B1E),
      AppColorsType.indicator: Color(0xFFF3EFE0),
      AppColorsType.error: Color(0xFFF3EFE0),
    },
  );
}

enum AppColorsType {
  primary,
  secondary,
  text,
  indicator,
  error;
}

enum AppThemeName {
  light,
  dark;

  static AppThemeName fromString(String? themeName) => {
    light.name: light,
    dark.name: dark,
  }[themeName] ?? light;
}