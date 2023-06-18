import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

extension ContextExtension on BuildContext {
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
