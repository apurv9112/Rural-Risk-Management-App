import 'package:flutter/material.dart';
import 'package:rrm/core/database/app_database.dart';
import 'package:rrm/core/storage/media_cleanup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.database;

  print("====== M12.1 METRICS VALIDATION START ======");

  final db = await AppDatabase.instance.database;
  
  // Total media rows
  final totalRes = await db.rawQuery('SELECT COUNT(*) as c FROM media_metadata');
  final totalRows = totalRes.first['c'] as int;
  print("Total media rows: $totalRows");

  // Total synced rows
  final syncedRes = await db.rawQuery('SELECT COUNT(*) as c FROM media_metadata WHERE sync_status = ?', ['COMPLETED']);
  final syncedRows = syncedRes.first['c'] as int;
  print("Total synced rows: $syncedRows");

  // Cutoff
  final cutoff = await MediaCleanupService.calculateRetentionCutoff();
  print("Retention Cutoff: $cutoff");

  // Total cleanup candidates
  if (cutoff != null) {
    final candidateRes = await db.rawQuery(
      'SELECT COUNT(*) as c FROM media_metadata WHERE sync_status = ? AND created_at < ?',
      ['COMPLETED', cutoff.toIso8601String()]
    );
    final candidateRows = candidateRes.first['c'] as int;
    print("Total cleanup candidates: $candidateRows");
    
    // Storage metrics
    final mediaSize = await MediaCleanupService.getMediaDirectorySize();
    print("Estimated storage currently used: $mediaSize bytes");
  }

  print("\\n====== M12.1 METRICS VALIDATION END ======");
}
