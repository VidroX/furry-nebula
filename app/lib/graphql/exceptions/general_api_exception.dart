import 'package:ferry/ferry.dart';

class GeneralApiException extends ServerException {
  final List<String> messages;

  const GeneralApiException({ this.messages = const [] });
}
