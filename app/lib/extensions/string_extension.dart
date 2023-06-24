import 'package:intl/intl.dart';

extension StringExtension on String {
  String get tryCapitalize {
    final parts = split(RegExp(r'\s'));
    
    return parts
        .map((e) => toBeginningOfSentenceCase(e) ?? e)
        .join(' ');
  }
}
