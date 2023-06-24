import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/app_theme.dart';
import 'package:furry_nebula/environment_constants.dart';
import 'package:furry_nebula/router/router.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  log('Starting app in ${EnvironmentConstants.environmentType} environment');

  await dotenv.load(fileName: '${EnvironmentConstants.environmentType}.env');

  usePathUrlStrategy();
  initDependencyInjector();

  final theme = await _loadTheme();

  runApp(MainApp(theme: theme));
}

Future<AppColorsTheme> _loadTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var themeName = prefs.getString(AppColors.themeKey);

  if (themeName == null) {
    final brightness = SchedulerBinding.instance
        .platformDispatcher
        .platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    themeName = isDarkMode
        ? AppThemeName.dark.name
        : AppThemeName.light.name;

    await prefs.setString(AppColors.themeKey, themeName);
  }

  return AppColorsTheme.fromString(themeName);
}

class MainApp extends StatelessWidget {
  final AppColorsTheme theme;

  final _appRouter = AppRouter();

  MainApp({
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppThemeProvider>(
    create: (_) => AppThemeProvider(theme: theme),
    child: Consumer<AppThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData().customTheme(
          theme: AppColors.fromThemeName(themeProvider.theme.themeName),
        ),
        supportedLocales: const [
          Locale('en'),
          Locale('uk'),
        ],
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              basePath: kIsWeb ? 'i18n' : 'assets/i18n',
            ),
            missingTranslationHandler: (key, locale) {
              log("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
            },
          ),
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
        ],
        routerConfig: _appRouter.config(),
        builder: FlutterI18n.rootAppBuilder(),
      ),
    ),
  );
}
