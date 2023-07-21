import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/translations.dart';

enum UserRequestType {
  accommodation,
  adoption;

  static UserRequestType? fromGUserRequestType(GUserRequestType requestType) => {
    GUserRequestType.Accommodation: accommodation,
    GUserRequestType.Adoption: adoption,
  }[requestType];

  GUserRequestType get toGUserRequestType => {
    accommodation: GUserRequestType.Accommodation,
    adoption: GUserRequestType.Adoption,
  }[this]!;

  String get translationKey => {
    accommodation: Translations.requestTypeAccommodation,
    adoption: Translations.requestTypeAdoption,
  }[this]!;
}
