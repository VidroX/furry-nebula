part of 'shelter_details_bloc.dart';

@freezed
class ShelterDetailsEvent with _$ShelterDetailsEvent {
  const factory ShelterDetailsEvent.getShelterById({
    required String id,
    Function(Shelter shelter)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetShelterById;

  const factory ShelterDetailsEvent.setShelter({
    required Shelter shelter,
  }) = SetShelter;
}
