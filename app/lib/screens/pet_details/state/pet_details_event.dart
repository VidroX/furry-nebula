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
}
