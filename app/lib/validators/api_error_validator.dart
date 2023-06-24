import 'package:furry_nebula/validators/validator.dart';

class ApiErrorValidator implements Validator<String> {
  final String fieldName;
  final Map<String, String> validationErrors;

  const ApiErrorValidator({
    required this.validationErrors,
    required this.fieldName,
  });

  @override
  String? validate(String? value) => validationErrors[fieldName];
}
