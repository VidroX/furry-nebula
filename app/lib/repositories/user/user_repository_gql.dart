import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:furry_nebula/graphql/__generated__/schema.schema.gql.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/graphql/exceptions/validation_exception.dart';
import 'package:furry_nebula/graphql/fragments/__generated__/user_fragment.data.gql.dart';
import 'package:furry_nebula/graphql/mutations/user/__generated__/change_user_approval_status.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/user/__generated__/login.req.gql.dart';
import 'package:furry_nebula/graphql/mutations/user/__generated__/register.req.gql.dart';
import 'package:furry_nebula/graphql/queries/user/__generated__/get_current_user.req.gql.dart';
import 'package:furry_nebula/graphql/queries/user/__generated__/get_user_approvals.req.gql.dart';
import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_registration_role.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/models/user/user_token.dart';
import 'package:furry_nebula/repositories/user/user_repository.dart';
import 'package:furry_nebula/services/api_client.dart';
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
    role: UserRole.fromGRole(user.role)!,
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
  Future<void> logout() async {
    client.ferryClient.cache.clear();

    await _storage.delete(key: UserToken.accessTokenKey);
    await _storage.delete(key: UserToken.refreshTokenKey);
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
      throw const RequestFailedException();
    }

    final accessToken = response.data!.login.accessToken!.token;
    final refreshToken = response.data!.login.refreshToken!.token;

    await _storage.write(key: UserToken.accessTokenKey, value: accessToken);
    await _storage.write(key: UserToken.refreshTokenKey, value: refreshToken);

    return _buildUser(response.data!.login.user!);
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDay,
    String? about,
    UserRegistrationRole role = UserRegistrationRole.user,
  }) async {
    final registrationInput = GUserRegistrationInputBuilder()
      ..email = email
      ..password = password
      ..firstName = firstName
      ..lastName = lastName
      ..birthday = birthDay
      ..about = about
      ..role = role.toGRegistrationRole;

    final request = GRegistrationMutationReq(
          (b) => b
            ..vars.userInfo = registrationInput,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException is ValidationException) {
      throw response.linkException!;
    }

    final hasErrors = response.data?.register.user == null
        || response.data?.register.accessToken?.token == null
        || response.data?.register.refreshToken?.token == null;

    if (hasErrors) {
      throw const RequestFailedException();
    }

    final accessToken = response.data!.register.accessToken!.token;
    final refreshToken = response.data!.register.refreshToken!.token;

    await _storage.write(key: UserToken.accessTokenKey, value: accessToken);
    await _storage.write(key: UserToken.refreshTokenKey, value: refreshToken);

    return _buildUser(response.data!.register.user!);
  }

  @override
  Future<GraphPage<User>> getUnapprovedUsers({
    Pagination pagination = const Pagination(),
  }) async {
    final filters = GApprovalFiltersBuilder()
      ..isApproved = false
      ..isReviewed = false;

    final request = GGetUserApprovalsReq(
          (b) => b
            ..vars.filters = filters
            ..vars.pagination = pagination.toGPaginationBuilder,
    );

    final response = await client.ferryClient.request(request).first;

    final hasErrors = response.data?.userApprovals.node == null
        || response.data?.userApprovals.pageInfo == null;

    if (hasErrors) {
      throw const RequestFailedException();
    }

    final pageInfo = response.data!.userApprovals.pageInfo;
    final users = response.data!.userApprovals.node
        .map((user) => _buildUser(user!))
        .toList();

    return GraphPage.fromFragment(
      nodes: users,
      pageInfo: pageInfo,
    );
  }

  @override
  Future<void> changeUserApprovalStatus({
    required String userId,
    bool isApproved = false,
  }) async {
    final request = GChangeUserApprovalStatusReq(
          (b) => b
            ..vars.userId = userId
            ..vars.isApproved = isApproved,
    );

    final response = await client.ferryClient.request(request).first;

    if (response.linkException != null) {
      throw const RequestFailedException();
    }
  }
}
