import 'package:sqflite/sqflite.dart';
import '../models/master_data_model.dart';
import 'base_dao.dart';

class MasterDataDao extends BaseDao {
  static const String tableName = 'master_data';

  Future<int> insert(MasterDataModel data) async {
    final database = await db;
    return await database.insert(
      tableName,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MasterDataModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      return MasterDataModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> update(MasterDataModel data) async {
    final database = await db;
    return await database.update(
      tableName,
      data.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [data.localUuid],
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
