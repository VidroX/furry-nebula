part of 'pets_bloc.dart';

@freezed
class PetsState with _$PetsState {
  const factory PetsState({
    @Default(false) bool isLoading,
    @Default(Pagination()) Pagination pagination,
    AnimalType? selectedAnimalType,
    List<Shelter>? selectedShelters,
    @Default([]) List<ShelterAnimal> shelterAnimals,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
