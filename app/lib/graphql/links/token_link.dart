import 'package:ferry/ferry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:furry_nebula/models/user/user_token.dart';
import 'package:gql_exec/gql_exec.dart';

class TokenLink extends Link {
  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  const TokenLink();

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final accessToken = await _storage.read(key: UserToken.accessTokenKey);
    final refreshToken = await _storage.read(key: UserToken.refreshTokenKey);

    final newRequest = request.withContextEntry(
      TokenContextEntry(
        UserToken(
          accessToken: accessToken ?? '',
          refreshToken: refreshToken ?? '',
        ),
      ),
    );

    final forwardedCall = forward?.call(newRequest);

    if (forwardedCall != null) {
      yield* forwardedCall;
    }
  }
}

class TokenContextEntry extends ContextEntry {
  final UserToken? tokens;

  const TokenContextEntry(this.tokens);

  @override
  List<Object?> get fieldsForEquality => [
    tokens,
  ];
}
