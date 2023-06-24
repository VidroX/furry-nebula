import 'package:furry_nebula/models/user/user.dart';

abstract class UserRepository {
  Future<User> login(String email, String password);
}
