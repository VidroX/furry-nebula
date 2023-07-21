import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/user_fragment.data.gql.dart';
import 'package:furry_nebula/models/user/user_role.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String firstName,
    required String lastName,
    @Default(UserRole.user) UserRole role,
    @Default('') String about,
    required String email,
    @Default(false) bool isApproved,
    required DateTime birthDay,
  }) = _User;

  factory User.fromFragment(GUserFragment fragment) => User(
    id: fragment.id,
    firstName: fragment.firstName,
    lastName: fragment.lastName,
    isApproved: fragment.isApproved,
    about: fragment.about,
    role: UserRole.fromGRole(fragment.role)!,
    email: fragment.email,
    birthDay: fragment.birthday,
  );

  const User._();

  String get fullName => '$firstName $lastName';
}
