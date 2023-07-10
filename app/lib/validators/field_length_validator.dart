import 'package:flutter/cupertino.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/validators/validator.dart';

class FieldLengthValidator implements Validator<String> {
  final BuildContext context;
  final int requiredLength;
  final bool countSurroundingWhitespace;

  const FieldLengthValidator(this.context, {
    this.requiredLength = 1,
    this.countSurroundingWhitespace = false,
  });

  @override
  String? validate(String? value) {
    if (value == null) {
      return context.translate(Translations.fieldRequiredError);
    }

    final meetsRequirements =
        (countSurroundingWhitespace && value.length >= requiredLength) || (
            !countSurroundingWhitespace &&
            value.trim().length >= requiredLength
        );

    return meetsRequirements
        ? null
        : context.translate(Translations.fieldRequiredError);
  }
}
