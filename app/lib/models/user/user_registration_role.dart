import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';

enum UserRegistrationRole {
  user,
  shelter;

  GRole get toGRole => {
    user: GRole.User,
    shelter: GRole.Shelter,
  }[this]!;

  static UserRegistrationRole? fromGRole(GRole role) => {
    GRole.User: user,
    GRole.Shelter: shelter,
  }[role];

  GRegistrationRole get toGRegistrationRole => {
    user: GRegistrationRole.User,
    shelter: GRegistrationRole.Shelter,
  }[this]!;

  static UserRegistrationRole? fromGRegistrationRole(GRegistrationRole role) => {
    GRegistrationRole.User: user,
    GRegistrationRole.Shelter: shelter,
  }[role];
}
