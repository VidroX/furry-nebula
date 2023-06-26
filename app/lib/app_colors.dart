import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_colors.freezed.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  static const String themeKey = 'theme';

  final AppColorsTheme theme;

  const AppColors({ required this.theme });

  factory AppColors.fromColorsTheme(AppColorsTheme theme) {
    switch (theme.themeName) {
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
        containerColor: Color.lerp(
          theme.containerColor,
          other.theme.containerColor,
          t,
        ) ?? theme.containerColor,
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
        neumorphicShadow: theme.neumorphicShadow.mapIndexed((index, shadow) =>
            BoxShadow.lerp(shadow, other.theme.neumorphicShadow[index], t) ?? shadow,
        ).toList(),
        shadow: theme.shadow.mapIndexed((index, shadow) =>
            BoxShadow.lerp(shadow, other.theme.shadow[index], t) ?? shadow,
        ).toList(),
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
    required Color containerColor,
    required Map<AppColorsType, Color> primaryColors,
    required Map<AppColorsType, Color> alternativeColors,
    required List<BoxShadow> neumorphicShadow,
    required List<BoxShadow> shadow,
  }) = _AppColorsTheme;

  const AppColorsTheme._();

  factory AppColorsTheme.fromAppThemeName(
      Brightness brightness,
      AppThemeName? themeName,
  ) {
    switch (themeName) {
      case AppThemeName.auto:
        return brightness == Brightness.dark
            ? AppColorsTheme.dark()
            : AppColorsTheme.light();
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
    backgroundColor: Color(0xFFFCFCFC),
    surfaceColor: Color(0xFFFFFFFF),
    containerColor: Color(0xFFFFFFFF),
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
    neumorphicShadow: [
      BoxShadow(
        color: Color(0xFFD9D9D9),
        offset: Offset(10, 10),
        blurRadius: 15,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color(0xFFFFFFFF),
        offset: Offset(-10, -10),
        blurRadius: 15,
        spreadRadius: 1,
      ),
    ],
    shadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 15,
        spreadRadius: -3,
        offset: Offset(0, 10),
      ),
    ],
  );

  factory AppColorsTheme.dark() => const AppColorsTheme(
    themeName: AppThemeName.dark,
    isLight: false,
    backgroundColor: Color(0xFF1B1B1E),
    surfaceColor: Color(0xFFFFFFFF),
    containerColor: Color(0xFF393941),
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
    neumorphicShadow: [
      BoxShadow(
        color: Color(0xFF17171A),
        blurRadius: 15,
        spreadRadius: 1,
        offset: Offset(-20, -20),
      ),
      BoxShadow(
        color: Color(0xFF1F1F23),
        blurRadius: 15,
        spreadRadius: 1,
        offset: Offset(20, 20),
      ),
    ],
    shadow: [
      BoxShadow(
        color: Color(0x40FFFFFF),
        blurRadius: 15,
        spreadRadius: -3,
        offset: Offset(0, 10),
      ),
    ],
  );

  Color get primary => primaryColors[AppColorsType.primary]!;
  Color get secondary => primaryColors[AppColorsType.secondary]!;
  Color get text => primaryColors[AppColorsType.text]!;
  Color get indicator => primaryColors[AppColorsType.indicator]!;
  Color get error => primaryColors[AppColorsType.error]!;

  Color get alternativePrimary => alternativeColors[AppColorsType.primary]!;
  Color get alternativeSecondary => alternativeColors[AppColorsType.secondary]!;
  Color get alternativeText => alternativeColors[AppColorsType.text]!;
  Color get alternativeIndicator => alternativeColors[AppColorsType.indicator]!;
  Color get alternativeError => alternativeColors[AppColorsType.error]!;
}

enum AppColorsType {
  primary,
  secondary,
  text,
  indicator,
  error;
}

enum AppThemeName {
  auto,
  light,
  dark;

  static AppThemeName fromString(String? themeName) => {
    auto.name: auto,
    light.name: light,
    dark.name: dark,
  }[themeName] ?? auto;
}
