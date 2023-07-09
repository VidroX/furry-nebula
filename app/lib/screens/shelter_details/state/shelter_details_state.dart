part of 'shelter_details_bloc.dart';

@freezed
class ShelterDetailsState with _$ShelterDetailsState {
  const factory ShelterDetailsState({
    @Default(false) bool isLoading,
    Shelter? shelter,
  }) = Initial;
}
