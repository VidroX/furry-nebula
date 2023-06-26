import "dart:developer";
import "dart:io";

import "package:dio/dio.dart";
import "package:ferry/ferry.dart";
import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:furry_nebula/environment_constants.dart";
import "package:furry_nebula/graphql/__generated__/schema.schema.gql.dart" show possibleTypesMap;
import "package:furry_nebula/graphql/exceptions/auth/invalid_token_exception.dart";
import "package:furry_nebula/graphql/exceptions/auth/token_refresh_failed_exception.dart";
import "package:furry_nebula/graphql/exceptions/exception_handler.dart" as handler;
import "package:furry_nebula/graphql/exceptions/general_api_exception.dart";
import "package:furry_nebula/graphql/exceptions/validation_exception.dart";
import "package:furry_nebula/graphql/links/token_link.dart";
import "package:furry_nebula/graphql/mutations/user/__generated__/refresh_token.req.gql.dart";
import "package:furry_nebula/models/user/user_token.dart";
import "package:gql_dedupe_link/gql_dedupe_link.dart";
import "package:gql_dio_link/gql_dio_link.dart";
import "package:gql_error_link/gql_error_link.dart";
import "package:gql_exec/gql_exec.dart" as gql;
import "package:gql_transform_link/gql_transform_link.dart";
import "package:jwt_decoder/jwt_decoder.dart";


class ApiClient {
  final Dio _client;

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  const ApiClient(Dio client) : _client = client;

  Client get ferryClient => _createClient([
    const TokenLink(),
    ErrorLink(onGraphQLError: _handleError),
    TransformLink(
      requestTransformer: (request) => _transformRequest(request, false),
    ),
    DedupeLink(),
  ]);

  Future<bool> _isRefreshTokenValid(TokenContextEntry? tokenEntry) async {
    final isInvalidToken = tokenEntry?.tokens?.refreshToken == null
        || JwtDecoder.isExpired(tokenEntry!.tokens!.refreshToken);

    if (isInvalidToken) {
      await _storage.delete(key: UserToken.accessTokenKey);
      await _storage.delete(key: UserToken.refreshTokenKey);

      return false;
    }

    return true;
  }

  Stream<gql.Response>? _handleError(
      gql.Request request,
      NextLink forward,
      gql.Response response,
  ) async* {
    if (response.errors?.isEmpty ?? true) {
      return;
    }

    final tokenEntry = request.context.entry<TokenContextEntry>();
    final Map<String, String> validationErrors = {};

    for (final error in response.errors!) {
      log('GraphQL Error: $error');

      final extensions = error.extensions;

      if (extensions == null) {
        continue;
      }

      final String? errorCode = extensions['errCode'] as String?;

      if (errorCode == null) {
        continue;
      }

      final exception = handler
          .ExceptionHandler(errorCode)
          .mapErrorCodeToException();

      if (exception == null) {
        continue;
      }

      final String message = error.message;
      final String? field = extensions['field'] as String?;

      if (exception is ValidationException && field != null) {
        validationErrors[field] = message;
      }

      final isTokenRefreshNeeded = exception is InvalidTokenException
          && await _isRefreshTokenValid(tokenEntry);

      if (isTokenRefreshNeeded) {
        log('Token refresh needed');

        final newAccessToken = await _updateToken();

        yield* forward(
          request.updateContextEntry<TokenContextEntry>(
                (entry) => TokenContextEntry(
                  entry?.tokens?.copyWith(accessToken: newAccessToken),
                ),
          ),
        );

        return;
      }
    }

    if (validationErrors.keys.isNotEmpty) {
      throw ValidationException(fieldsValidationMap: validationErrors);
    }

    throw GeneralApiException(
      messages: response.errors?.map((e) => e.message).toList() ?? [],
    );
  }

  Client _createClient(List<Link> links) {
    final link = Link.from([
      ...links,
      DioLink(
        dotenv.env[EnvironmentConstants.apiEndpoint] ?? '',
        client: _client,
      ),
    ]);

    // ignore: avoid_redundant_argument_values
    final cache = Cache(possibleTypes: possibleTypesMap);

    return Client(link: link, cache: cache);
  }

  gql.Request _transformRequest(gql.Request request, bool withRefreshToken) {
    log("Transforming request: ${request.operation.operationName}");
    final tokenEntry = request.context.entry<TokenContextEntry>();

    final token = withRefreshToken
        ? tokenEntry?.tokens?.refreshToken ?? ''
        : tokenEntry?.tokens?.accessToken ?? '';

    return request.updateContextEntry<HttpLinkHeaders>(
          (headers) => HttpLinkHeaders(
            headers: <String, String>{
              ...headers?.headers ?? <String, String>{},
              "Authorization": 'Bearer $token',
              if (!kIsWeb)
                "Accept-Language": Platform.localeName.replaceAll('_', '-'),
            },
          ),
    );
  }

  Future<String> _updateToken() async {
    final newClient = _createClient([
      const TokenLink(),
      TransformLink(
        requestTransformer: (request) => _transformRequest(request, true),
      ),
      DedupeLink(),
    ]);

    final request = GRefreshAccessTokenReq();
    final response = await newClient.request(request).first;

    final hasErrors = response.linkException != null
        || (response.data?.refreshAccessToken.token.isEmpty ?? true);

    if (hasErrors) {
      throw const TokenRefreshFailedException();
    }

    final accessToken = response.data!.refreshAccessToken.token;

    await _storage.write(key: UserToken.accessTokenKey, value: accessToken);

    return accessToken;
  }
}
