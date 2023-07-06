part of 'pets_bloc.dart';

@freezed
class PetsEvent with _$PetsEvent {
  const factory PetsEvent.getAnimals({
    Function(GraphPage<ShelterAnimal> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetAnimals;

  const factory PetsEvent.nextPage({
    Function(GraphPage<ShelterAnimal> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetAnimalsNextPage;

  const factory PetsEvent.setSheltersFilter({
    List<Shelter>? shelters,
  }) = SetSheltersFilter;

  const factory PetsEvent.setAnimalTypeFilter({
    AnimalType? animalType,
  }) = SetAnimalTypeFilter;
}
