part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String email,
    required String password,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = Login;

  const factory AuthEvent.register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDay,
    String? about,
    @Default(UserRegistrationRole.user) UserRegistrationRole role,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = Register;

  const factory AuthEvent.clearValidationErrors({
    String? field,
  }) = ClearValidationErrors;
}
