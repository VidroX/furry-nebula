import 'package:furry_nebula/models/user/user.dart';

abstract class UserRepository {
  Future<bool> isAuthenticated();

  Future<User> getCurrentUser();

  Future<User> login(String email, String password);

  Future<void> logout();
}
