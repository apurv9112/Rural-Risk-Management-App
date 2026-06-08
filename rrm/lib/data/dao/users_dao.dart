import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import 'base_dao.dart';

class UsersDao extends BaseDao {
  static const String tableName = 'users';

  Future<int> insert(UserModel user) async {
    final database = await db;
    return await database.insert(
      tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(UserModel user) async {
    final database = await db;
    return await database.update(
      tableName,
      user.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [user.localUuid],
    );
  }

  Future<int> delete(String localUuid) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
  }
}
