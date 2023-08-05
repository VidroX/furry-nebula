import 'dart:io';

import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formatToYearMonthDay =>
      DateFormat(DateFormat.YEAR_MONTH_DAY, Platform.localeName).format(this);
}
