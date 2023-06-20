import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_token.freezed.dart';

@freezed
class UserToken with _$UserToken {
  static const String accessTokenKey = 'nebula-at';
  static const String refreshTokenKey = 'nebula-rt';

  const factory UserToken({
    required String accessToken,
    required String refreshToken,
  }) = _UserToken;
}
