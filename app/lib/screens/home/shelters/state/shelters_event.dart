part of 'shelters_bloc.dart';

@freezed
class SheltersEvent with _$SheltersEvent {
  const factory SheltersEvent.getShelters({
    @Default(true) bool clearFetch,
    bool? showOnlyOwnShelters,
    Function(GraphPage<Shelter> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetShelters;

  const factory SheltersEvent.nextPage({
    bool? showOnlyOwnShelters,
    Function(GraphPage<Shelter> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetSheltersNextPage;

  const factory SheltersEvent.addShelter({
    required PhotoObject<AddShelterData> shelterData,
    Function(Shelter shelter)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = AddShelter;
}
