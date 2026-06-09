import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../core/storage/folder_manager.dart';
import '../models/media_metadata_model.dart';
import 'base_dao.dart';

class MediaDao extends BaseDao {
  static const String tableName = 'media_metadata';

  Future<int> insert(MediaMetadataModel media) async {
    final database = await db;
    return await database.insert(
      tableName,
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<MediaMetadataModel?> getById(String localUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'local_uuid = ?',
      whereArgs: [localUuid],
    );
    if (maps.isNotEmpty) {
      final model = MediaMetadataModel.fromMap(maps.first);
      return await _migrateLegacyMediaIfNeeded(model);
    }
    return null;
  }

  Future<List<MediaMetadataModel>> getByCattleId(String cattleUuid) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'cattle_uuid = ? AND deleted_at IS NULL',
      whereArgs: [cattleUuid],
    );
    final List<MediaMetadataModel> results = [];
    for (var e in maps) {
      results.add(await _migrateLegacyMediaIfNeeded(MediaMetadataModel.fromMap(e)));
    }
    return results;
  }

  Future<List<MediaMetadataModel>> getArchivedMediaForCleanup(String dateThreshold) async {
    final database = await db;
    final List<Map<String, dynamic>> maps = await database.query(
      tableName,
      where: 'sync_status = ? AND created_at < ?',
      whereArgs: ['ARCHIVED', dateThreshold],
    );
    return maps.map((e) => MediaMetadataModel.fromMap(e)).toList();
  }

  Future<int> update(MediaMetadataModel media) async {
    final database = await db;
    return await database.update(
      tableName,
      media.toMap(),
      where: 'local_uuid = ?',
      whereArgs: [media.localUuid],
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

  Future<MediaMetadataModel> _migrateLegacyMediaIfNeeded(MediaMetadataModel model) async {
    final absoluteLocalPath = model.absoluteLocalPath;
    if (absoluteLocalPath == null || absoluteLocalPath.isEmpty) {
      return model;
    }

    final file = File(absoluteLocalPath);
    
    // If it already has YYYY/MM pattern, or file is missing, skip migration.
    // Using RegExp to check for a year/month pattern like \202\d\\\d\d\
    if (RegExp(r'\d{4}[\\/]\d{2}[\\/]').hasMatch(absoluteLocalPath) || !(await file.exists())) {
      return model;
    }

    // Determine workflow type from current path if possible, fallback to 'tagging'
    String workflow = 'tagging';
    if (absoluteLocalPath.contains('retagging')) workflow = 'retagging';
    if (absoluteLocalPath.contains('claim')) workflow = 'claim';

    try {
      final createdAt = DateTime.tryParse(model.createdAt ?? '') ?? DateTime.now();
      final targetFolder = await FolderManager.getPartitionedMediaFolder(workflow, createdAt);
      final fileName = p.basename(file.path);
      final destinationPath = p.join(targetFolder, fileName);
      
      await file.copy(destinationPath);
      await file.delete(); // move complete
      
      final updatedModel = model.copyWith(absoluteLocalPath: destinationPath);
      await update(updatedModel);
      return updatedModel;
    } catch (e) {
      return model; // Fail gracefully
    }
  }
}
