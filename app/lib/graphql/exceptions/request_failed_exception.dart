import 'package:ferry/ferry.dart';
import 'package:furry_nebula/translations.dart';

class RequestFailedException extends ServerException {
  final String message;

  const RequestFailedException({ this.message = Translations.requestFailedError });

  @override
  String toString() => message;
}
