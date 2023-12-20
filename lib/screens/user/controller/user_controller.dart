import 'package:flutter_practical_task_etech/screens/user/model/user_model.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserController extends GetxController {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY, name TEXT, email TEXT, country TEXT, registrationDate TEXT, userImage TEXT, city TEXT, state TEXT, postcode TEXT, age TEXT, birthDate TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (index) {
      return User(
        name: maps[index]['name'],
        email: maps[index]['email'],
        country: maps[index]['country'],
        registrationDate: maps[index]['registrationDate'],
        userImage: maps[index]['userImage'],
        city: maps[index]['city'],
        state: maps[index]['state'],
        postcode: maps[index]['postcode'],
        age: maps[index]['age'],
        birthDate: maps[index]['date'],
      );
    });
  }
}
