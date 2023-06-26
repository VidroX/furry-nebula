import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';

part 'pagination.freezed.dart';

@freezed
class Pagination with _$Pagination {
  const factory Pagination({
    @Default(1) int page,
    @Default(10) int resultsPerPage,
  }) = _Pagination;

  const Pagination._();

  Pagination get nextPage => copyWith(page: page + 1);

  Pagination get prevPage => page - 1 > 0
      ? copyWith(page: page - 1)
      : this;

  GPaginationBuilder get toGPaginationBuilder => GPaginationBuilder()
      ..page = page
      ..resultsPerPage = resultsPerPage;
}
