import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/page_info_fragment.data.gql.dart';

part 'graph_page.freezed.dart';

@freezed
class GraphPage<T> with _$GraphPage<T> {
  const factory GraphPage({
    required List<T> nodes,
    required GraphPageInfo pageInfo,
  }) = _GraphPage;

  const GraphPage._();

  factory GraphPage.fromFragment({
    required List<T> nodes,
    required GPageInfoFragment pageInfo,
  }) => GraphPage(nodes: nodes, pageInfo: GraphPageInfo.fromFragment(pageInfo));
}

@freezed
class GraphPageInfo with _$GraphPageInfo {
  const factory GraphPageInfo({
    @Default(1) int page,
    @Default(false) bool hasNextPage,
    @Default(false) bool hasPreviousPage,
    @Default(0) int resultsPerPage,
    @Default(0) int totalResults,
  }) = _GraphPageInfo;

  const GraphPageInfo._();

  factory GraphPageInfo.fromFragment(GPageInfoFragment pageInfo) =>
      GraphPageInfo(
        page: pageInfo.page ?? 1,
        hasNextPage: pageInfo.hasNextPage,
        hasPreviousPage: pageInfo.hasPreviousPage,
        resultsPerPage: pageInfo.resultsPerPage,
        totalResults: pageInfo.totalResults,
      );
}
