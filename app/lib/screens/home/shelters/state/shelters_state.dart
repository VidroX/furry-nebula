part of 'shelters_bloc.dart';

@freezed
class SheltersState with _$SheltersState {
  const factory SheltersState({
    @Default(false) bool isLoading,
    @Default(Pagination()) Pagination pagination,
    @Default([]) List<Shelter> shelters,
    @Default(GraphPageInfo()) GraphPageInfo pageInfo,
  }) = Initial;
}
