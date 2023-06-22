

import 'package:sofia_test_app/models/user.dart';

abstract class IAuthService {
  Future<bool> isLoggedAsync();
  Future<bool> loginAsync(String username, String password);
  Future<bool> logoutAsync();
  Future<User> detailsAsync();
}
