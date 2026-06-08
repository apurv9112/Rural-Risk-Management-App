import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/media_manager.dart';
import '../models/media_metadata_model.dart';
import 'base_repository.dart';

class MediaRepository extends BaseRepository {
  static const String mediaTable = 'media_metadata';

  /// Saves media to permanent storage and inserts metadata into the database.
  /// If the DB insert fails, physically deletes the copied file to prevent orphans.
  Future<void> saveDraftMedia({
    required File tempFile,
    required String workflowType,
    required String targetFileName,
    required MediaMetadataModel metadata,
  }) async {
    // 1. Move file via MediaManager
    final permanentPath = await MediaManager.moveMediaToPermanentStorage(
      tempFile: tempFile,
      workflowType: workflowType,
      targetFileName: targetFileName,
    );

    if (permanentPath == null) throw Exception('Failed to copy media file.');

    // 2. Wrap DB insert in a try-catch to enable physical rollback
    final database = await db;
    try {
      await database.transaction((txn) async {
        // We override the absoluteLocalPath in the model to guarantee it matches
        final Map<String, dynamic> insertMap = metadata.toMap();
        insertMap['absolute_local_path'] = permanentPath;

        await txn.insert(
          mediaTable,
          insertMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
    } catch (e) {
      // 3. Rollback: Delete the orphaned physical file
      final fileToClean = File(permanentPath);
      if (await fileToClean.exists()) {
        await fileToClean.delete();
      }
      rethrow;
    }
  }
}
