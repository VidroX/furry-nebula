import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_registration_role.dart';

abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<User> getCurrentUser();

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

  Future<void> logout();
}
