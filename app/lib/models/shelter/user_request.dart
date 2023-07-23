import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/user_request_fragment.data.gql.dart';
import 'package:furry_nebula/models/shelter/shelter_animal.dart';
import 'package:furry_nebula/models/shelter/user_request_status.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/models/user/user.dart';

part 'user_request.freezed.dart';

@freezed
class UserRequest with _$UserRequest {
  const factory UserRequest({
    required String id,
    required UserRequestType requestType,
    required UserRequestStatus requestStatus,
    required User user,
    required ShelterAnimal animal,
    User? approvedBy,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _UserRequest;

  factory UserRequest.fromFragment(GUserRequestFragment fragment) =>
      UserRequest(
        id: fragment.id,
        requestType: UserRequestType.fromGUserRequestType(fragment.requestType)
            ?? UserRequestType.accommodation,
        requestStatus: UserRequestStatus.fromGUserRequestStatus(fragment.requestStatus)
            ?? UserRequestStatus.pending,
        user: User.fromFragment(fragment.user),
        animal: ShelterAnimal.fromFragment(fragment.animal),
        approvedBy: fragment.approvedBy != null
            ? User.fromFragment(fragment.approvedBy!)
            : null,
        fromDate: fragment.fromDate,
        toDate: fragment.toDate,
      );

  const UserRequest._();
}
