import 'package:floor/floor.dart';

@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  final int id;

  @ColumnInfo(name: 'email')
  final String email;

  @ColumnInfo(name: 'username')
  final String username;

  @ColumnInfo(name: 'password')
  final String password;

  User(this.id, this.email, this.username, this.password); // Generated constructor
}
