part of 'user_requests_bloc.dart';

@freezed
class UserRequestsEvent with _$UserRequestsEvent {
  const factory UserRequestsEvent.getRequests({
    @Default(true) bool clearFetch,
    UserRequestsFilters? filters,
    Function(GraphPage<UserRequest> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetUserRequests;

  const factory UserRequestsEvent.nextPage({
    UserRequestsFilters? filters,
    Function(GraphPage<UserRequest> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetUserRequestsNextPage;

  const factory UserRequestsEvent.setFilters({
    @Default(UserRequestsFilters()) UserRequestsFilters filters,
  }) = SetRequestFilters;

  const factory UserRequestsEvent.createRequest({
    required String animalId,
    required UserRequestType requestType,
    DateTime? fromDate,
    DateTime? toDate,
    Function(UserRequest userRequest)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = CreateRequest;

  const factory UserRequestsEvent.changeRequestStatus({
    required String requestId,
    @Default(false) bool isApproved,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = ChangeRequestStatus;

  const factory UserRequestsEvent.changeRequestFulfillmentStatus({
    required String requestId,
    @Default(false) bool isFulfilled,
    VoidCallback? onSuccess,
    Function(ServerException? exception)? onError,
  }) = ChangeRequestFulfillmentStatus;
}
