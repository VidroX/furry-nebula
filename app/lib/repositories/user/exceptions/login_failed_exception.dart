import 'package:ferry/ferry.dart';
import 'package:furry_nebula/translations.dart';

class LoginFailedException extends ServerException {
  String get message => Translations.authSignInError;

  const LoginFailedException();

  @override
  String toString() => message;
}
