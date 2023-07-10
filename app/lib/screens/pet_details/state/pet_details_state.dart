part of 'pet_details_bloc.dart';

@freezed
class PetDetailsState with _$PetDetailsState {
  const factory PetDetailsState({
    @Default(false) bool isLoading,
    ShelterAnimal? shelterAnimal,
  }) = Initial;
}
