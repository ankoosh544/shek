import 'package:floor/floor.dart';

@Entity(tableName: 'User')
class User {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'email')
  final String email;

  @ColumnInfo(name: 'username')
  final String username;

  @ColumnInfo(name: 'password')
  final String password;

  @ColumnInfo(name: 'Visual')
  final bool isVisual = false;

  @ColumnInfo(name: 'Audio')
  final bool isAudio = false;

  @ColumnInfo(name: 'Screen touch')
  final bool isScreenTouch = false;

  @ColumnInfo(name: 'President')
  final bool isPresident = false;

  @ColumnInfo(name: 'Disable People')
  final bool isDisablePeople = false;

  User(this.id, this.email, this.username, this.password);
}
