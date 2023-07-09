import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:furry_nebula/app_colors.dart';
import 'package:furry_nebula/app_theme.dart';
import 'package:furry_nebula/graphql/exceptions/general_api_exception.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';
import 'package:provider/provider.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppColorsTheme get colors =>
      theme.extension<AppColors>()?.theme ?? AppColorsTheme.light();

  AppThemeProvider get themeProvider =>
      Provider.of<AppThemeProvider>(this, listen: false);

  NebulaGlobalNotificationProvider get notificationProvider =>
      Provider.of<NebulaGlobalNotificationProvider>(this, listen: false);

  void showNotification(NebulaNotification notification) =>
      notificationProvider.showNotification(notification);

  void cancelNotification() => notificationProvider.cancelNotification();

  NebulaTextStyle get typography => NebulaTextStyle(
    color: colors.text,
    fontSize: AppFontSize.normal.asValue,
  );

  NebulaTextStyle get typographyAlt => NebulaTextStyle(
    color: colors.alternativeText,
    fontSize: AppFontSize.normal.asValue,
  );

  bool get isLandscape =>
      MediaQuery.of(this).size.width >= MediaQuery.of(this).size.height;

  bool get isPortrait => !isLandscape;

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

  void showApiError(ServerException? e) {
    if (e == null) {
      return;
    }

    String? message;

    if (e is GeneralApiException) {
      message = e.messages[0];
    } else if (e is ValidationException) {
      message = e.fieldsValidationMap.values.toList()[0];
    } else if (e is RequestFailedException) {
      message = e.message;
    }

    if (message == null) {
      return;
    }

    showNotification(
      NebulaNotification.error(
        title: translate(Translations.error),
        description: translate(message),
      ),
    );
  }
}
