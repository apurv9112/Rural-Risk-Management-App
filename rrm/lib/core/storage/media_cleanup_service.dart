import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/storage/folder_manager.dart';

class MediaCleanupService {
  /// Total storage size in bytes
  static Future<int> getMediaDirectorySize() async {
    final mediaFolder = await FolderManager.getFolderPath('media');
    final dir = Directory(mediaFolder);
    if (!await dir.exists()) return 0;
    
    int totalBytes = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    } catch (e) {
      debugPrint("Error calculating media directory size: $e");
    }
    return totalBytes;
  }

  /// Calculates the retention cutoff based on current storage usage
  static Future<DateTime?> calculateRetentionCutoff() async {
    final sizeBytes = await getMediaDirectorySize();
    final sizeGB = sizeBytes / (1024 * 1024 * 1024);

    if (sizeGB > 10) {
      return DateTime.now().subtract(const Duration(days: 7));
    } else if (sizeGB > 5) {
      return DateTime.now().subtract(const Duration(days: 30));
    } else {
      return DateTime.now().subtract(const Duration(days: 90));
    }
  }

  /// Executes cleanup in batches of 100 to prevent locking
  static Future<void> executeCleanup() async {
    final cutoff = await calculateRetentionCutoff();
    if (cutoff == null) return;

    final db = await AppDatabase.instance.database;

    while (true) {
      // 1. Fetch Candidates (Batch Size 100)
      final List<Map<String, dynamic>> candidates = await db.query(
        'media_metadata',
        columns: ['local_uuid', 'absolute_local_path'],
        where: 'sync_status = ? AND created_at < ?',
        whereArgs: ['COMPLETED', cutoff.toIso8601String()],
        limit: 100,
      );

      if (candidates.isEmpty) break; // Stop condition: End of result set

      // 2. Process Batch
      for (final candidate in candidates) {
        final localUuid = candidate['local_uuid'] as String;
        final absolutePath = candidate['absolute_local_path'] as String;

        try {
          // Delete physical file
          final file = File(absolutePath);
          if (await file.exists()) {
            await file.delete();
          }

          // Delete DB row
          await db.delete(
            'media_metadata',
            where: 'local_uuid = ?',
            whereArgs: [localUuid],
          );
        } catch (e) {
          // Failure handling: Log and continue
          debugPrint("Failed to cleanup media $localUuid: $e");
        }
      }
    }
  }
}
