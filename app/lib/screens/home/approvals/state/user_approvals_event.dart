part of 'user_approvals_bloc.dart';

@freezed
class UserApprovalsEvent with _$UserApprovalsEvent {
  const factory UserApprovalsEvent.getUnapprovedUsers({
    @Default(true) bool clearFetch,
    Function(GraphPage<User> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetUnapprovedUsers;

  const factory UserApprovalsEvent.nextPage({
    Function(GraphPage<User> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetUnapprovedUsersNextPage;

  const factory UserApprovalsEvent.changeUserStatus({
    required User user,
    @Default(false) bool isApproved,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = ChangeUserStatus;

  const factory UserApprovalsEvent.removeUser({
    required String userId,
  }) = RemoveUser;
}
