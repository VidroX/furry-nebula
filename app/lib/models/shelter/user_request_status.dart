import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/translations.dart';

enum UserRequestStatus {
  approved,
  cancelled,
  denied,
  fulfilled,
  pending;

  static UserRequestStatus? fromGUserRequestStatus(GUserRequestStatus requestStatus) => {
    GUserRequestStatus.Approved: approved,
    GUserRequestStatus.Cancelled: cancelled,
    GUserRequestStatus.Denied: denied,
    GUserRequestStatus.Fulfilled: fulfilled,
    GUserRequestStatus.Pending: pending,
  }[requestStatus];

  GUserRequestStatus get toGUserRequestStatus => {
    approved: GUserRequestStatus.Approved,
    cancelled: GUserRequestStatus.Cancelled,
    denied: GUserRequestStatus.Denied,
    fulfilled: GUserRequestStatus.Fulfilled,
    pending: GUserRequestStatus.Pending,
  }[this]!;

  String get translationKey => {
    approved: Translations.userRequestStatusesApproved,
    cancelled: Translations.userRequestStatusesCancelled,
    denied: Translations.userRequestStatusesDenied,
    fulfilled: Translations.userRequestStatusesFulfilled,
    pending: Translations.userRequestStatusesPending,
  }[this]!;
}
