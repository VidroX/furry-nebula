import 'package:furry_nebula/graphql/mutations/auth/__generated__/login.req.gql.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/repositories/user/exceptions/login_failed_exception.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/services/api_client.dart';

class UserRepositoryGraphQL extends UserRepository {
  final ApiClient client;

  UserRepositoryGraphQL({ required this.client });

  @override
  Future<User> login(String email, String password) async {
    final request = GLoginMutationReq(
          (b) => b
            ..vars.email = email
            ..vars.password = password,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.data?.login.user == null) {
      throw const LoginFailedException();
    }

    return User(
      id: response.data!.login.user!.id,
      firstName: response.data!.login.user!.firstName,
      lastName: response.data!.login.user!.lastName,
      isApproved: response.data!.login.user!.isApproved,
      about: response.data!.login.user!.about,
      role: response.data!.login.user!.role,
      email: response.data!.login.user!.email,
    );
  }
}
