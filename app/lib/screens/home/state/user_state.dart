part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
    @Default(false) bool isLoading,
    @Default(false) bool isLogoutLoading,
    @Default(null) User? user,
  }) = Initial;

  const UserState._();

  bool hasRole(UserRole role) => user != null
      && user!.role.power >= role.power
      && user!.isApproved;
}
