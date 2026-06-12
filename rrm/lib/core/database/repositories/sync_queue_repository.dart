import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:rrm/services/offline/queue_models.dart';
import '../app_database.dart';

class SyncQueueRepository {
  final AppDatabase _appDatabase;

  SyncQueueRepository(this._appDatabase);

  Future<Database> get db => _appDatabase.database;

  Future<void> insert(SyncQueue queue) async {
    final database = await db;
    await database.insert(
      'sync_queue',
      _toMap(queue),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(SyncQueue queue) async {
    final database = await db;
    await database.update(
      'sync_queue',
      _toMap(queue),
      where: 'id = ?',
      whereArgs: [queue.id],
    );
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<SyncQueue?> getById(String id) async {
    final database = await db;
    final maps = await database.query(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _fromMap(maps.first);
    }
    return null;
  }

  Future<List<SyncQueue>> getAll() async {
    final database = await db;
    final maps = await database.query('sync_queue');
    return maps.map((map) => _fromMap(map)).toList();
  }

  Future<List<SyncQueue>> getByStates(List<SyncState> states) async {
    if (states.isEmpty) return [];
    final database = await db;
    final stateNames = states.map((s) => s.name).toList();
    final placeholders = List.filled(states.length, '?').join(',');
    final maps = await database.query(
      'sync_queue',
      where: 'state IN ($placeholders)',
      whereArgs: stateNames,
    );
    return maps.map((map) => _fromMap(map)).toList();
  }

  Map<String, dynamic> _toMap(SyncQueue queue) {
    return {
      'id': queue.id,
      'state': queue.state.name,
      'payload': jsonEncode(queue.payload),
      'createdAt': queue.createdAt.millisecondsSinceEpoch,
      'updatedAt': queue.updatedAt.millisecondsSinceEpoch,
    };
  }

  SyncQueue _fromMap(Map<String, dynamic> map) {
    return SyncQueue(
      id: map['id'] as String,
      state: SyncState.values.firstWhere((e) => e.name == map['state']),
      payload: jsonDecode(map['payload'] as String) as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }
}
