import 'package:ferry/ferry.dart';
import 'package:furry_nebula/translations.dart';

class ValidationException extends ServerException {
  static const String errorCode = 'errors.validation';

  String get message => Translations.validationError;

  final Map<String, String> fieldsValidationMap;

  const ValidationException({ this.fieldsValidationMap = const {} });
}
