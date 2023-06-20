import 'package:ferry/ferry.dart';
import 'package:furry_nebula/translations.dart';

class TokenRefreshFailedException extends ServerException {
  String get message => Translations.invalidTokenError;

  const TokenRefreshFailedException();
}
