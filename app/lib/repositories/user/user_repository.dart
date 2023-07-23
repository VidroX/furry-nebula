import 'package:furry_nebula/models/pagination/graph_page.dart';
import 'package:furry_nebula/models/pagination/pagination.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_registration_role.dart';

abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<User> getCurrentUser();

  Future<void> logout();

  Future<User> login(String email, String password);

  Future<User> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDay,
    String? about,
    UserRegistrationRole role = UserRegistrationRole.user,
  });

  Future<GraphPage<User>> getUnapprovedUsers({
    bool shouldGetFromCacheFirst = true,
    Pagination pagination = const Pagination(),
  });

  Future<void> changeUserApprovalStatus({
    required String userId,
    bool isApproved = false,
  });
}
