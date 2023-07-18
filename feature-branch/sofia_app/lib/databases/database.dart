// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/models/user.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [User])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
}
