import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/translations.dart';

enum UserRole {
  user,
  shelter,
  admin;

  GRole get toGRole => {
    user: GRole.User,
    shelter: GRole.Shelter,
  }[this]!;

  static UserRole? fromGRole(GRole role) => {
    GRole.User: user,
    GRole.Shelter: shelter,
    GRole.Admin: admin,
  }[role];

  GRole get toGRRole => {
    user: GRole.User,
    shelter: GRole.Shelter,
    admin: GRole.Admin,
  }[this]!;

  static UserRole? fromGRegistrationRole(GRegistrationRole role) => {
    GRegistrationRole.User: user,
    GRegistrationRole.Shelter: shelter,
  }[role];

  String get translationKey => {
    user: Translations.user,
    shelter: Translations.shelterRepresentative,
    admin: Translations.admin,
  }[this] ?? Translations.user;

  int get power => {
    user: 1,
    shelter: 2,
    admin: 100,
  }[this]!;
}
