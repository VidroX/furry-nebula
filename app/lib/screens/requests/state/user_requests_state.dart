part of 'user_requests_bloc.dart';

@freezed
class UserRequestsState with _$UserRequestsState {
  const factory UserRequestsState({
    @Default(false) bool isLoading,
    @Default(false) bool isCreatingRequest,
    @Default(false) bool isChangingStatus,
    @Default(Pagination()) Pagination pagination,
    @Default(UserRequestsFilters()) UserRequestsFilters filters,
    @Default([]) List<UserRequest> userRequests,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
