import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/graphql/mutations/auth/__generated__/login.req.gql.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_token.dart';
import 'package:furry_nebula/repositories/user/exceptions/login_failed_exception.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/services/api_client.dart';

class UserRepositoryGraphQL extends UserRepository {
  final ApiClient client;

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  UserRepositoryGraphQL({ required this.client });

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
      throw const LoginFailedException();
    }

    final accessToken = response.data!.login.accessToken!.token;
    final refreshToken = response.data!.login.refreshToken!.token;

    await _storage.write(key: UserToken.accessTokenKey, value: accessToken);
    await _storage.write(key: UserToken.refreshTokenKey, value: refreshToken);

    return User(
      id: response.data!.login.user!.id,
      firstName: response.data!.login.user!.firstName,
      lastName: response.data!.login.user!.lastName,
      isApproved: response.data!.login.user!.isApproved,
      about: response.data!.login.user!.about,
      role: response.data!.login.user!.role,
      email: response.data!.login.user!.email,
      birthDay: response.data!.login.user!.birthday,
    );
  }
}
