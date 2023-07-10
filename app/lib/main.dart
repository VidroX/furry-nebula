import 'dart:developer';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/app_theme.dart';
import 'package:furry_nebula/environment_constants.dart';
import 'package:furry_nebula/router/router.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  log('Starting app in ${EnvironmentConstants.environmentType} environment');

  WidgetsFlutterBinding.ensureInitialized();

  await FastCachedImageConfig.init(
    subDir: (await getApplicationDocumentsDirectory()).path,
    clearCacheAfter: const Duration(days: 7),
  );

  usePathUrlStrategy();
  initDependencyInjector();

  final theme = await _loadTheme();

  runApp(MainApp(theme: theme));
}

Future<AppThemeName> _loadTheme() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final themeName = prefs.getString(AppColors.themeKey);

  if (themeName == null) {
    await prefs.setString(AppColors.themeKey, AppThemeName.auto.name);
  }

  return AppThemeName.fromString(themeName);
}

class MainApp extends StatefulWidget {
  final AppThemeName theme;

  const MainApp({
    required this.theme,
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final _appRouter = AppRouter();

  late final _themeProvider = AppThemeProvider(
    currentThemeName: widget.theme,
    theme: AppColorsTheme.fromAppThemeName(
      MediaQuery.of(context).platformBrightness,
      widget.theme,
    ),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    if (widget.theme == AppThemeName.auto &&
        _themeProvider.currentThemeName == AppThemeName.auto) {

      final brightness = WidgetsBinding.instance
          .platformDispatcher
          .platformBrightness;

      _themeProvider.changeTheme(
        brightness == Brightness.dark
            ? AppColorsTheme.dark()
            : AppColorsTheme.light(),
        changeCurrentThemeName: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppThemeProvider>(
    create: (_) => _themeProvider,
    child: Consumer<AppThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData().customTheme(
          theme: AppColors.fromColorsTheme(themeProvider.theme),
        ),
        supportedLocales: const [
          Locale('en'),
          Locale('uk'),
        ],
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              basePath: 'assets/i18n',
            ),
          ),
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
        ],
        routerConfig: _appRouter.config(),
        builder: (context, child) => Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => _AppContainer(child: child)),
          ],
        ),
      ),
    ),
  );
}

class _AppContainer extends StatefulWidget {
  final Widget? child;

  const _AppContainer({
    this.child,
    // ignore: unused_element
    super.key,
  });

  @override
  State<_AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<_AppContainer> with NebulaNotificationHandler {
  @override
  Widget build(BuildContext context) => Provider<NebulaGlobalNotificationProvider>(
    create: (_) => NebulaGlobalNotificationProvider(
      showNotification: showNotification,
      cancelNotification: cancelNotification,
    ),
    builder: FlutterI18n.rootAppBuilder(),
    child: widget.child,
  );
}
