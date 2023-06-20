import 'package:ferry/ferry.dart';
import 'package:furry_nebula/graphql/exceptions/auth/invalid_token_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';

class ExceptionHandler {
  final String errorCode;

  ExceptionHandler(this.errorCode);

  final Map<String, ServerException> _errorCodeMap = {
    InvalidTokenException.errorCode: const InvalidTokenException(),
    ValidationException.errorCode: const ValidationException(),
  };

  ServerException? mapErrorCodeToException() {
    if (errorCode.isEmpty) {
      return null;
    }

    final errorCodeParts = errorCode.split('.');
    final generalError = '${errorCodeParts[0]}.${errorCodeParts[1]}';

    if (_errorCodeMap.keys.contains(errorCode)) {
      return _errorCodeMap[errorCode];
    }

    if (_errorCodeMap.keys.contains(generalError)) {
      return _errorCodeMap[generalError];
    }

    return null;
  }
}
