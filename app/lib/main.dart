import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furry_nebula/environment_constants.dart';
import 'package:furry_nebula/router/router.dart';
import 'package:furry_nebula/services/injector.dart';

Future<void> main() async {
  log('Starting app in ${EnvironmentConstants.environmentType} environment');

  await dotenv.load(fileName: '${EnvironmentConstants.environmentType}.env');

  usePathUrlStrategy();
  initDependencyInjector();

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final _appRouter = AppRouter();

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(basePath: '/assets/i18n'),
          missingTranslationHandler: (key, locale) {
            log("--- Missing Key: $key, languageCode: ${locale?.languageCode}");
          },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      routerConfig: _appRouter.config(),
      builder: FlutterI18n.rootAppBuilder(),
    );
  }
}
