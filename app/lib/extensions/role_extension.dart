import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/translations.dart';

extension RoleExtension on GRole {
  String get translationKey => {
    GRole.User: Translations.user,
    GRole.Shelter: Translations.shelterRepresentative,
    GRole.Admin: Translations.admin,
  }[this] ?? Translations.user;
}
