part of 'pet_details_bloc.dart';

@freezed
class PetDetailsEvent with _$PetDetailsEvent {
  const factory PetDetailsEvent.getShelterAnimalById({
    required String id,
    Function(ShelterAnimal shelterAnimal)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetShelterAnimalById;

  const factory PetDetailsEvent.setShelterAnimal({
    required ShelterAnimal shelterAnimal,
  }) = SetShelterAnimal;

  const factory PetDetailsEvent.updateShelterAnimalRating({
    required String id,
    required double rating,
    Function(ShelterAnimal shelterAnimal)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = UpdateShelterAnimalRating;
}
