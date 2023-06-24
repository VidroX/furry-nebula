import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/user_fragment.data.gql.dart';
import 'package:furry_nebula/graphql/mutations/auth/__generated__/login.req.gql.dart';
import 'package:furry_nebula/graphql/queries/auth/__generated__/get_current_user.req.gql.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_token.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/services/api_client.dart';
import 'package:furry_nebula/translations.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserRepositoryGraphQL extends UserRepository {
  final ApiClient client;

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  UserRepositoryGraphQL({ required this.client });

  User _buildUser(GUserFragment user) => User(
    id: user.id,
    firstName: user.firstName,
    lastName: user.lastName,
    isApproved: user.isApproved,
    about: user.about,
    role: user.role,
    email: user.email,
    birthDay: user.birthday,
  );

  @override
  Future<bool> isAuthenticated() async {
    final refreshToken = await _storage.read(key: UserToken.refreshTokenKey);

    return refreshToken != null && !JwtDecoder.isExpired(refreshToken);
  }

  @override
  Future<User> getCurrentUser() async {
    final request = GGetCurrentUserReq();

    final cachedUser = client.ferryClient.cache.readQuery(request);

    if (cachedUser != null) {
      return _buildUser(cachedUser.user);
    }

    final response = await client.ferryClient.request(request).first;
    final user = response.data?.user;

    if (user == null) {
      throw const RequestFailedException();
    }

    return _buildUser(user);
  }

  @override
  Future<User> login(String email, String password) async {
    final request = GLoginMutationReq(
          (b) => b
            ..vars.email = email
            ..vars.password = password,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException is ValidationException) {
      throw response.linkException!;
    }

    final hasErrors = response.data?.login.user == null
        || response.data?.login.accessToken?.token == null
        || response.data?.login.refreshToken?.token == null;

    if (hasErrors) {
      throw const RequestFailedException(message: Translations.authSignInError);
    }

    final accessToken = response.data!.login.accessToken!.token;
    final refreshToken = response.data!.login.refreshToken!.token;

    await _storage.write(key: UserToken.accessTokenKey, value: accessToken);
    await _storage.write(key: UserToken.refreshTokenKey, value: refreshToken);

    return _buildUser(response.data!.login.user!);
  }

  @override
  Future<void> logout() async {
    client.ferryClient.cache.clear();

    await _storage.delete(key: UserToken.accessTokenKey);
    await _storage.delete(key: UserToken.refreshTokenKey);
  }
}
