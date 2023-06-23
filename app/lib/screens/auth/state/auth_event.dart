part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String email,
    required String password,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = Login;

  const factory AuthEvent.clearValidationErrors({
    String? field,
  }) = ClearValidationErrors;
}
