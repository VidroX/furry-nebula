part of 'pets_bloc.dart';

@freezed
class PetsState with _$PetsState {
  const factory PetsState({
    @Default(false) bool isLoading,
    @Default(false) bool isAddingPet,
    @Default(Pagination()) Pagination pagination,
    @Default(PetsFilter()) PetsFilter filters,
    @Default([]) List<ShelterAnimal> shelterAnimals,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
