part of 'user_approvals_bloc.dart';

@freezed
class UserApprovalsState with _$UserApprovalsState {
  const factory UserApprovalsState({
    @Default(false) bool isLoading,
    @Default([]) List<User> pendingApprovalUsers,
    @Default([]) List<User> pendingRejectionUsers,
    @Default(Pagination()) Pagination pagination,
    @Default([]) List<User> userApprovals,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
