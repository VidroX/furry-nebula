part of 'shelters_bloc.dart';

@freezed
class SheltersEvent with _$SheltersEvent {
  const factory SheltersEvent.getShelters({
    bool? showOnlyOwnShelters,
    Function(GraphPage<Shelter> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetShelters;

  const factory SheltersEvent.nextPage({
    bool? showOnlyOwnShelters,
    Function(GraphPage<Shelter> page)? onSuccess,
    Function(ServerException? exception)? onError,
  }) = GetSheltersNextPage;
}
