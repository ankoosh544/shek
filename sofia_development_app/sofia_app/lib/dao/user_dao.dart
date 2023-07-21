import 'package:floor/floor.dart';
import 'package:sofia_app/models/user.dart';


@dao
abstract class UserDao {
  @Query('SELECT * FROM User')
  Future<List<User>> getAllUsers();

@Query('SELECT * FROM User WHERE id = :id')
Future<User?> getUserById(int id);


  @Query('SELECT * FROM User WHERE username = :username')
  Future<User?> getUserByUsername(String username);

  @insert
  Future<void> registerUser(User user);

  @update
  Future<void> updateUser(User user);

  @delete
  Future<void> deleteUser(User user);
}
