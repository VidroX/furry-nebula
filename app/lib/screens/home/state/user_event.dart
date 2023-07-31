part of 'user_bloc.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.getCurrentUser({
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetCurrentUser;

  const factory UserEvent.logout({ VoidCallback? onFinish }) = Logout;

  const factory UserEvent.updateFCMToken({
    required String token,
  }) = UpdateFCMToken;
}
