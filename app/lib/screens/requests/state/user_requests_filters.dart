import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';

part 'user_requests_filters.freezed.dart';

@freezed
class UserRequestsFilters with _$UserRequestsFilters {
  const factory UserRequestsFilters({
    UserRequestType? requestType,
    bool? showOwnRequests,
    @Default(false) bool? isApproved,
    @Default(false) bool? isReviewed,
  }) = _UserRequestsFilters;

  const UserRequestsFilters._();

  GUserRequestFiltersBuilder get toGUserRequestFiltersBuilder => GUserRequestFiltersBuilder()
    ..requestType = requestType?.toGUserRequestType
    ..showOwnRequests = showOwnRequests
    ..isApproved = isApproved
    ..isReviewed = isReviewed;

  bool get isEmpty => requestType == null
      && (showOwnRequests == null || !showOwnRequests!)
      && (isApproved == null || !isApproved!)
      && (isReviewed == null || !isReviewed!);
}
