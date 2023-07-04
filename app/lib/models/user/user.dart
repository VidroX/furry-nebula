import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String firstName,
    required String lastName,
    @Default(GRole.User) GRole role,
    @Default('') String about,
    required String email,
    @Default(false) bool isApproved,
    required DateTime birthDay,
  }) = _User;

  const User._();

  String get fullName => '$firstName $lastName';
}
