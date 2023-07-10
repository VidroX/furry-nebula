part of 'shelters_bloc.dart';

@freezed
class SheltersState with _$SheltersState {
  const factory SheltersState({
    @Default(false) bool isLoading,
    @Default(false) bool isAddingShelter,
    @Default(false) bool isDeletingShelter,
    @Default(Pagination()) Pagination pagination,
    @Default([]) List<Shelter> shelters,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
