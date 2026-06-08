import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';

class SyncMutex {
  static const String _mutexKey = 'sync_lock';
  
  /// Acquires the sync lock. Returns true if successfully acquired, false if already locked.
  Future<bool> acquireLock() async {
    final db = await AppDatabase.instance.database;
    
    // First, cleanup any stale lock (>15 minutes old)
    await clearStaleLock(db);

    try {
      final now = DateTime.now().toIso8601String();
      await db.insert(
        'app_settings',
        {
          'key': _mutexKey,
          'value': now,
          'updated_at': now,
        },
        // We do NOT use replace. If it exists, it should throw or we use ConflictAlgorithm.abort.
        // Wait, 'key' is PRIMARY KEY, so insert without replace will fail if it exists.
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true; // Successfully acquired
    } catch (e) {
      // If it fails due to UNIQUE constraint, someone else has the lock
      return false;
    }
  }

  /// Releases the sync lock.
  Future<void> releaseLock() async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_mutexKey],
    );
  }

  /// Clears the lock if it's older than 15 minutes.
  Future<void> clearStaleLock(Database db) async {
    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [_mutexKey],
    );

    if (result.isNotEmpty) {
      final lockedAtStr = result.first['value'] as String?;
      if (lockedAtStr != null) {
        final lockedAt = DateTime.tryParse(lockedAtStr);
        if (lockedAt != null && DateTime.now().difference(lockedAt).inMinutes > 15) {
          // Stale lock detected
          await db.delete(
            'app_settings',
            where: 'key = ?',
            whereArgs: [_mutexKey],
          );
        }
      }
    }
  }
}
