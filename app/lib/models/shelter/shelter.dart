import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/shelter_fragment.data.gql.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_role.dart';

part 'shelter.freezed.dart';

@freezed
class Shelter with _$Shelter {
  const factory Shelter({
    required String id,
    required String name,
    required String address,
    @Default('') String info,
    String? photo,
    required User representativeUser,
  }) = _Shelter;

  factory Shelter.fromFragment(GShelterFragment fragment) => Shelter(
    id: fragment.id,
    name: fragment.name,
    address: fragment.address,
    info: fragment.info,
    photo: fragment.photo,
    representativeUser: User(
      id: fragment.representativeUser.id,
      firstName: fragment.representativeUser.firstName,
      lastName: fragment.representativeUser.lastName,
      isApproved: fragment.representativeUser.isApproved,
      about: fragment.representativeUser.about,
      role: UserRole.fromGRole(fragment.representativeUser.role)!,
      email: fragment.representativeUser.email,
      birthDay: fragment.representativeUser.birthday,
    ),
  );

  const Shelter._();
}
