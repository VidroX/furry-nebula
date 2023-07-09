part of 'pets_bloc.dart';

@freezed
class PetsEvent with _$PetsEvent {
  const factory PetsEvent.getAnimals({
    @Default(true) bool clearFetch,
    PetsFilter? filters,
    Function(GraphPage<ShelterAnimal> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetAnimals;

  const factory PetsEvent.nextPage({
    PetsFilter? filters,
    Function(GraphPage<ShelterAnimal> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetAnimalsNextPage;

  const factory PetsEvent.setFilters({
    @Default(PetsFilter()) PetsFilter filters,
  }) = SetFilters;

  const factory PetsEvent.addPet({
    required String shelterId,
    required PhotoObject<AddShelterAnimalData> petData,
    Function(ShelterAnimal pet)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = AddPet;
}
