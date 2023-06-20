import 'package:ferry/ferry.dart';
import 'package:furry_nebula/translations.dart';

class InvalidTokenException extends ServerException {
  static const String errorCode = 'errors.1.3';

  String get message => Translations.invalidTokenError;

  const InvalidTokenException();
}
