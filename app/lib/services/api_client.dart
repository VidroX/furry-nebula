import "dart:developer";
import "dart:io";

import "package:dio/dio.dart";
import "package:ferry/ferry.dart";
import "package:flutter/foundation.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:furry_nebula/environment_constants.dart";
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
  final Client _client;

  Client get ferryClient => _client;

  const ApiClient({
    required Client client,
  }) : _client = client;

  factory ApiClient.init({
    required Cache cache,
    required Dio client,
  }) {
    final clientHandler = _ApiClientHandler(cache: cache);

    return ApiClient(client: createClient(
      dioClient: client,
      ferryCache: cache,
      links: [
        const TokenLink(),
        ErrorLink(onGraphQLError: clientHandler.handleError),
        TransformLink(
          requestTransformer: (request) =>
              clientHandler.transformRequest(request, false),
        ),
        DedupeLink(),
      ],
    ),);
  }

  static Client createClient({
    required Dio dioClient,
    required Cache ferryCache,
    List<Link> links = const [],
  }) {
    final link = Link.from([
      ...links,
      DioLink(
        EnvironmentConstants.apiEndpoint,
        client: dioClient,
      ),
    ]);

    return Client(link: link, cache: ferryCache);
  }
}

class _ApiClientHandler {
  final Cache cache;

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  const _ApiClientHandler({ required this.cache });

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

  gql.Request transformRequest(gql.Request request, bool withRefreshToken) {
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
    final newClient = ApiClient.createClient(
      dioClient: Dio(),
      ferryCache: cache,
      links: [
        const TokenLink(),
        TransformLink(
          requestTransformer: (request) => transformRequest(request, true),
        ),
        DedupeLink(),
      ],
    );

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

  Stream<gql.Response>? handleError(
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
}
