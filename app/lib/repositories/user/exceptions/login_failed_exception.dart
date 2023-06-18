import 'package:furry_nebula/translations.dart';

class LoginFailedException implements Exception {
  String get message => Translations.signInError;

  const LoginFailedException();

  @override
  String toString() => message;
}
