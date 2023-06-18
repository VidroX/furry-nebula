import "package:dio/dio.dart";
import "package:ferry/ferry.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:furry_nebula/environment_constants.dart";
import "package:furry_nebula/graphql/__generated__/schema.schema.gql.dart" show possibleTypesMap;
import "package:gql_dedupe_link/gql_dedupe_link.dart";
import "package:gql_dio_link/gql_dio_link.dart";

class ApiClient {
  final Dio _client;

  const ApiClient(Dio client) : _client = client;

  Client get ferryClient {
    final link = Link.from([
      DedupeLink(),
      DioLink(
        dotenv.env[EnvironmentConstants.apiEndpoint] ?? '',
        client: _client,
      ),
    ]);

    // ignore: avoid_redundant_argument_values
    final cache = Cache(possibleTypes: possibleTypesMap);

    return Client(link: link, cache: cache);
  }
}
