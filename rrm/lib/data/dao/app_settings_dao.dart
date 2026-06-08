import 'package:sqflite/sqflite.dart';
import '../models/app_setting_model.dart';
import 'base_dao.dart';

class AppSettingsDao extends BaseDao {
  static const String tableName = 'app_settings';

  Future<int> insert(AppSettingModel setting) async {
    final database = await db;
    return await database.insert(
      tableName,
      setting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AppSettingModel?> getByKey(String key) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return AppSettingModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(AppSettingModel setting) async {
    final database = await db;
    return await database.update(
      tableName,
      setting.toMap(),
      where: 'key = ?',
      whereArgs: [setting.key],
    );
  }

  Future<int> delete(String key) async {
    final database = await db;
    return await database.delete(
      tableName,
      where: 'key = ?',
      whereArgs: [key],
    );
  }
}
